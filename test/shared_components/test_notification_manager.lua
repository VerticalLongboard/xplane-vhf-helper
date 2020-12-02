NotificationManager = require("vr-radio-helper.shared_components.notification_manager")
TestNotificationManager = {
    States = {
        Pending = NotificationManager.Constants.NotificationStates.Pending,
        Acknowledged = NotificationManager.Constants.NotificationStates.Acknowledged
    }
}
function TestNotificationManager:testPostedNotificationsArePendingAndNeedToBeAcknowledgedOnlyOnce()
    local nid = "dakl;f;kadlsf"
    local nm = NotificationManager:new()
    luaUnit.assertIsFalse(nm:isPending(nid))
    luaUnit.assertIsFalse(nm:areAnyNotificationsPending())
    nm:postOnce(nid)
    luaUnit.assertIsTrue(nm:isPending(nid))
    luaUnit.assertIsTrue(nm:areAnyNotificationsPending())
    nm:acknowledge(nid)
    luaUnit.assertIsFalse(nm:isPending(nid))
    luaUnit.assertIsFalse(nm:areAnyNotificationsPending())
    nm:postOnce(nid)
    luaUnit.assertIsFalse(nm:isPending(nid))
    luaUnit.assertIsFalse(nm:areAnyNotificationsPending())
end
function TestNotificationManager:testRepostedNotificationsArePendingAgain()
    local nid = "dakl;f;kadlsf"
    local nm = NotificationManager:new()
    luaUnit.assertIsFalse(nm:isPending(nid))
    luaUnit.assertIsFalse(nm:areAnyNotificationsPending())
    nm:repost(nid)
    luaUnit.assertIsTrue(nm:isPending(nid))
    luaUnit.assertIsTrue(nm:areAnyNotificationsPending())
    nm:acknowledge(nid)
    luaUnit.assertIsFalse(nm:isPending(nid))
    luaUnit.assertIsFalse(nm:areAnyNotificationsPending())
    nm:repost(nid)
    luaUnit.assertIsTrue(nm:isPending(nid))
    luaUnit.assertIsTrue(nm:areAnyNotificationsPending())
end
function TestNotificationManager:testStateIsSavedAndLoadedCorrectly()
    local nid = "dakl;f;kadlsf"
    local nid2 = "hmm"
    local nm = NotificationManager:new()
    nm:postOnce(nid)
    nm:postOnce(nid2)
    nm:acknowledge(nid)
    local state = {}
    nm:saveState(state)
    luaUnit.assertEquals(state[nid], self.States.Acknowledged)
    luaUnit.assertEquals(state[nid2], self.States.Pending)
    local nm2 = NotificationManager:new()
    nm2:loadState(state)
    luaUnit.assertIsFalse(nm2:isPending(nid))
    luaUnit.assertIsTrue(nm2:isPending(nid2))
end
