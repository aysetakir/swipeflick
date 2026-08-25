struct OnboardingModel {
    let title: String
    let subtitle: String
    let imageName: String
}

let onboardingInfos : [OnboardingModel] = [
    OnboardingModel(
        title: "onboardingTitle1".translated,
        subtitle: "onboardingSubtitle1".translated,
        imageName: "onboardingImage1"
    ),
    OnboardingModel(
        title: "onboardingTitle2".translated,
        subtitle: "onboardingSubtitle2".translated,
        imageName: "onboardingImage2"
    ),
    OnboardingModel(
        title: "onboardingTitle3".translated,
        subtitle: "onboardingSubtitle3".translated,
        imageName: "onboardingImage3"
    )
]
