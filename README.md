<!--

This source file is part of the ENGAGE-HF iOS open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->

# ENGAGE-HF

[![Build and Test](https://github.com/SchmiedmayerLab/ENGAGE-HF-iOS/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/SchmiedmayerLab/ENGAGE-HF-iOS/actions/workflows/build-and-test.yml)
[![Deployment](https://github.com/SchmiedmayerLab/ENGAGE-HF-iOS/actions/workflows/deployment.yml/badge.svg)](https://github.com/SchmiedmayerLab/ENGAGE-HF-iOS/actions/workflows/deployment.yml)
[![Codecov](https://codecov.io/gh/SchmiedmayerLab/ENGAGE-HF-iOS/graph/badge.svg?token=sFNNo3AoNd)](https://codecov.io/gh/SchmiedmayerLab/ENGAGE-HF-iOS)
[![REUSE status](https://api.reuse.software/badge/github.com/SchmiedmayerLab/ENGAGE-HF-iOS)](https://api.reuse.software/info/github.com/SchmiedmayerLab/ENGAGE-HF-iOS)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)

ENGAGE-HF is the iOS app of a heart failure home-monitoring study. Participants take weight and blood pressure readings on Bluetooth Low Energy devices; the app records them, syncs them to the study backend, and surfaces the medication recommendations the backend derives from recent vitals trends and KCCQ-12 survey responses.


## Features

|![home-screen-less-crowded](https://github.com/user-attachments/assets/2735c038-8abd-4f2d-91fa-fad9dcc5bba0)|![heart-health-weight-graph-overview](https://github.com/user-attachments/assets/f8ec1f2d-8895-4b4b-9161-cd75ed87966f)|![medications-expanded](https://github.com/user-attachments/assets/b627b757-2522-498d-8b67-fdb4fa7b7dd8)|
|:--:|:--:|:--:|
|Home|Heart Health|Medications|

|![education-expanded](https://github.com/user-attachments/assets/72def7c7-4f6f-4dfe-bde1-a92f194f5598)|![symptom-survey](https://github.com/user-attachments/assets/42b457a3-7943-4ffd-a5cb-afff16e58df1)|![bluetooth-measurement](https://github.com/user-attachments/assets/50b5f1d9-383d-44b6-9350-7bd135259890)|
|:--:|:--:|:--:|
|Education|Symptom Survey|Bluetooth|

- **Home** shows messages generated on the backend — reminders, survey prompts, and pointers to new recommendations — next to the most recent vitals.
- **Heart Health** charts weight, heart rate, blood pressure, and symptom score trends with [Swift Charts](https://developer.apple.com/documentation/charts) and lets participants review, add, and delete individual measurements.
- **Medications** presents the medication recommendations the backend algorithm derives from vitals and survey responses.
- **Education** offers videos about the app, the study, and common heart failure medications.
- **Symptom Survey** collects the KCCQ-12 questionnaire, defined as an [HL7 FHIR Questionnaire](https://build.fhir.org/questionnaire-definitions.html) and stored in Firestore together with its responses.
- **Bluetooth** pairs the weight scale and blood pressure cuff once; afterwards, measurements appear in the app the moment they are taken.

The app is server-driven: messages, recommendations, questionnaires, and educational content all originate on a [Firebase](https://firebase.google.com/docs) backend, maintained in [ENGAGE-HF-Firebase](https://github.com/SchmiedmayerLab/ENGAGE-HF-Firebase) and included here as a submodule.


## Build and Run the Application

Clone the repository together with its backend submodule:
```bash
git clone --recurse-submodules git@github.com:SchmiedmayerLab/ENGAGE-HF-iOS.git
```

During development the app talks to the [Firebase Local Emulator Suite](https://firebase.google.com/docs/emulator-suite/install_and_configure). Start a seeded instance with the Firebase CLI and Node.js:
```bash
cd ENGAGE-HF-Firebase && npm run prepare && npm run serve:seeded
```
or use the docker-based setup:
```bash
cd ENGAGE-HF-Firebase && docker-compose up
```

The emulator UI at http://127.0.0.1:4000/firestore/ shows the seeded data. A seeded emulator is also required to run the UI test suite. The [ENGAGE-HF-Firebase](https://github.com/SchmiedmayerLab/ENGAGE-HF-Firebase) repository documents the backend in more detail.

Open **ENGAGEHF.xcodeproj** in [Xcode](https://developer.apple.com/xcode/) and run the app; simulator builds connect to the local emulator automatically.

## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/SchmiedmayerLab/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/SchmiedmayerLab/.github/blob/main/CODE_OF_CONDUCT.md) first. You can find a list of contributors in the [CONTRIBUTORS.md](CONTRIBUTORS.md) file.

## License

This project is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for more information.

## Citation

If you use this software, please cite it using the metadata in [CITATION.cff](CITATION.cff), which GitHub surfaces through the [*Cite this repository*](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-citation-files) button.

## Our Research

For more information, visit the [Schmiedmayer Lab GitHub organization](https://github.com/SchmiedmayerLab).

![Schmiedmayer Lab](https://raw.githubusercontent.com/SchmiedmayerLab/.github/main/assets/footer-light.png#gh-light-mode-only)
![Schmiedmayer Lab](https://raw.githubusercontent.com/SchmiedmayerLab/.github/main/assets/footer-dark.png#gh-dark-mode-only)
