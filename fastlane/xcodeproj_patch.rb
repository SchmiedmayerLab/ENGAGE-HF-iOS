#
# This source file is part of the ENGAGE-HF iOS open-source project
#
# SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#

require "xcodeproj"

# Xcodeproj drops attributes it does not know when it writes a project back, and it does not know
# the traits Xcode records for a package reference. Fastlane opens and saves the project to set the
# bundle identifier and the build number, which removed the ResearchKit trait and left the archive
# without the types that trait provides. Declaring the attribute keeps the round trip lossless.
#
# This can be removed once Xcodeproj knows the attribute itself.
module Xcodeproj
  class Project
    module Object
      class XCRemoteSwiftPackageReference < AbstractObject
        attribute :traits, Array
      end
    end
  end
end
