//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Firebase
import FirebaseAuth
import FirebaseFunctions
import os
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirestore


final class InvitationCodeModule: Module, EnvironmentAccessible, @unchecked Sendable {
    @Application(\.logger) private var logger

    @Dependency(Account.self) private var account: Account?
    @Dependency(FirebaseAccountService.self) private var accountService: FirebaseAccountService?
    
    @Dependency(VideoManager.self) private var videoManager
    @Dependency(UserMetaDataManager.self) private var userMetaDataManager
    @Dependency(MedicationsManager.self) private var medicationsManager
    @Dependency(NotificationManager.self) private var notificationManager
    @Dependency(MessageManager.self) private var messageManager
    @Dependency(NavigationManager.self) private var navigationManager
    @Dependency(VitalsManager.self) private var vitalsManager


    func configure() {
        if FeatureFlags.useFirebaseEmulator && !FeatureFlags.disableFirebase {
            let firestoreHost = FeatureFlags.useCustomFirestoreHost ? FirestoreSettings.customHost : FirestoreSettings.defaultHost
            Functions.functions().useEmulator(withHost: firestoreHost, port: 5001)
        }
    }

    func verifyOnboardingCode(_ invitationCode: String) async throws {
        do {
            if FeatureFlags.disableFirebase {
                guard invitationCode == "ENGAGEHFTEST1" else {
                    throw InvitationCodeError.invitationCodeInvalid
                }
                
                try? await Task.sleep(for: .seconds(0.25))
            } else {
                do {
                    logger.debug("About to enroll user")
                    let enrollUser = Functions.functions().httpsCallable("enrollUser")
                    _ = try await enrollUser.call(["invitationCode": invitationCode])
                    _ = try? await Auth.auth().currentUser?.getIDToken(forcingRefresh: true)
                    
                    // Now that we've forced refresh on the auth token, refresh the content of the managers.
                    videoManager.refreshContent()
                    await userMetaDataManager.refreshContent()
                    await medicationsManager.refreshContent()
                    notificationManager.refreshContent()
                    await messageManager.refreshContent()
                    navigationManager.refreshContent()
                    await vitalsManager.refreshContent()

                    if !(await waitForInvitationCode()) {
                        logger.warning("Enrolled successfully, but the invitation code has not reached the account details yet.")
                    }

                    logger.debug("Successfully enrolled user!")
                } catch {
                    logger.error("Failed to enroll user: \(error)")
                    throw InvitationCodeError.invitationCodeInvalid
                }
            }
        } catch let error as NSError {
            if let errorCode = FunctionsErrorCode(rawValue: error.code) {
                // Handle Firebase-specific errors.
                switch errorCode {
                case .unauthenticated:
                    throw InvitationCodeError.userNotAuthenticated
                case .notFound:
                    throw InvitationCodeError.invitationCodeInvalid
                default:
                    throw InvitationCodeError.generalError(error.localizedDescription)
                }
            } else {
                // Handle other errors, such as network issues or unexpected behavior.
                throw InvitationCodeError.generalError(error.localizedDescription)
            }
        }
    }

    /// Waits until the invitation code reaches the local account details through the Firestore listener.
    ///
    /// Enrollment happens server-side, but the account sheet only dismisses once the code arrives in
    /// ``AccountDetails``; treating enrollment as complete before that leaves a window in which the app
    /// still shows the invitation prompt and a relaunch strands the account signed in but unenrolled.
    @discardableResult
    private func waitForInvitationCode(timeout: Duration = .seconds(10)) async -> Bool {
        guard let account else {
            return false
        }
        let deadline = ContinuousClock.now.advanced(by: timeout)
        while ContinuousClock.now < deadline {
            if await account.details?.invitationCode != nil {
                return true
            }
            try? await Task.sleep(for: .milliseconds(100))
        }
        return await account.details?.invitationCode != nil
    }

    func setupTestEnvironment(invitationCode: String) async throws {
        guard let account, let accountService else {
            guard FeatureFlags.disableFirebase else {
                preconditionFailure("The Firebase Account Service is required to be configured when setting up the test environment!")
            }
            return
        }

        let email = "test@engage.stanford.edu"
        let password = "123456789"

        if await account.details != nil {
            // always start logged out, even if testing account had already been set up
            try await accountService.logout()
            try await Task.sleep(for: .seconds(1))
        }

        var loggedIn = false
        do {
            try await accountService.login(userId: email, password: password)
            loggedIn = true
        } catch FirebaseAccountError.invalidCredentials {
            // probably doesn't exist. We try to create a new one below
        } catch {
            logger.error("Failed logging into test account: \(error)")
            throw error
        }

        if loggedIn {
            // A previous run can create this account and terminate before enrollment completes, so a
            // successful login does not imply the account carries an invitation code.
            if !(await waitForInvitationCode(timeout: .seconds(5))) {
                try await verifyOnboardingCode(invitationCode)
            }
            return
        }
        
        do {
            var details = AccountDetails()
            details.userId = email
            details.password = password
            details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
            try await accountService.signUp(with: details)
            try await Task.sleep(for: .seconds(1))
            try await verifyOnboardingCode(invitationCode)
        } catch {
            logger.error("Failed setting up test account : \(error)")
            throw error
        }
    }
}
