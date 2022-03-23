extension MainViewController {
    open override func updateUserActivityState(_ activity: NSUserActivity) {
        NSLog("SiriUserActivityDelegate updateUserActivityState");
        guard let activityName = SiriShortcuts.getActivityName() else { return }

        if activity.activityType == activityName {
            if let userInfo = ActivityDataHolder.getUserInfo() {
                activity.addUserInfoEntries(from: userInfo)
            }
        }
    }
}
