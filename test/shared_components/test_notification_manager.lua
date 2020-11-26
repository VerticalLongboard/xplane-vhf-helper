NotificationManager = require("shared_components.notification_manager")
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
    nm:postOnce(nid)
    luaUnit.assertIsTrue(nm:isPending(nid))
    nm:acknowledge(nid)
    luaUnit.assertIsFalse(nm:isPending(nid))
    nm:postOnce(nid)
    luaUnit.assertIsFalse(nm:isPending(nid))
end
function TestNotificationManager:testRepostedNotificationsArePendingAgain()
    local nid = "dakl;f;kadlsf"
    local nm = NotificationManager:new()
    luaUnit.assertIsFalse(nm:isPending(nid))
    nm:repost(nid)
    luaUnit.assertIsTrue(nm:isPending(nid))
    nm:acknowledge(nid)
    luaUnit.assertIsFalse(nm:isPending(nid))
    nm:repost(nid)
    luaUnit.assertIsTrue(nm:isPending(nid))
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
