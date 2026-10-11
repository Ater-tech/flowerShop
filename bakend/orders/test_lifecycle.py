import unittest

from orders.domain.lifecycle import (
    Action, Actor, ActionNotAllowed, FulfillmentMethod as M, InvalidTransition,
    MethodNotAvailable, Notice, OrderStatus as S, SellerOptions,
    allowed_actions, available_methods, can_review, ensure_method_available,
    notices_for, request_priority, stage_for, transition,
)


class TransitionTests(unittest.TestCase):
    def test_happy_path(self):
        s = transition(S.NEW, Action.ACCEPT, Actor.SELLER)
        self.assertEqual(s, S.ACCEPTED)
        self.assertEqual(transition(s, Action.COMPLETE, Actor.BUYER), S.COMPLETED)

    def test_buyer_cannot_accept(self):
        with self.assertRaises(ActionNotAllowed):
            transition(S.NEW, Action.ACCEPT, Actor.BUYER)

    def test_archived_is_final(self):
        for st in (S.COMPLETED, S.REJECTED, S.CANCELLED, S.EXPIRED):
            with self.assertRaises(InvalidTransition):
                transition(st, Action.CANCEL, Actor.BUYER)

    def test_only_system_expires(self):
        with self.assertRaises(ActionNotAllowed):
            transition(S.NEW, Action.EXPIRE, Actor.SELLER)

    def test_allowed_actions_for_ui(self):
        self.assertEqual(set(allowed_actions(S.NEW, Actor.SELLER)),
                         {Action.ACCEPT, Action.REJECT})
        self.assertEqual(allowed_actions(S.NEW, Actor.BUYER), [Action.CANCEL])


class MethodTests(unittest.TestCase):
    def test_defaults(self):
        self.assertEqual(available_methods(SellerOptions()), [M.PICKUP, M.MEETUP])

    def test_unavailable_method(self):
        with self.assertRaises(MethodNotAvailable):
            ensure_method_available(SellerOptions(), M.SELLER_DELIVERY)

    def test_priority_order(self):
        order = sorted(M, key=request_priority)
        self.assertEqual(order, [M.PICKUP, M.TAXI, M.SELLER_DELIVERY, M.MEETUP])


class StageTests(unittest.TestCase):
    def test_buyer_stages(self):
        self.assertEqual(stage_for(S.ACCEPTED, M.SELLER_DELIVERY, Actor.BUYER), "incoming")
        self.assertEqual(stage_for(S.ACCEPTED, M.PICKUP, Actor.BUYER), "pickup_in_progress")
        self.assertEqual(stage_for(S.ACCEPTED, M.TAXI, Actor.BUYER), "pickup_in_progress")

    def test_seller_and_archive(self):
        self.assertEqual(stage_for(S.ACCEPTED, M.PICKUP, Actor.SELLER), "agreed")
        self.assertEqual(stage_for(S.COMPLETED, M.PICKUP, Actor.BUYER), "archived")
        self.assertEqual(stage_for(S.NEW, M.PICKUP, Actor.BUYER), "pending")


class NoticeAndReviewTests(unittest.TestCase):
    def test_taxi_notices(self):
        self.assertEqual(len(notices_for(M.TAXI, Actor.BUYER)), 2)
        self.assertEqual(notices_for(M.TAXI, Actor.SELLER), [Notice.TAXI_SELLER_HANDS_TO_DRIVER])

    def test_delivery_notice_both_sides(self):
        for a in (Actor.BUYER, Actor.SELLER):
            self.assertEqual(notices_for(M.SELLER_DELIVERY, a),
                             [Notice.NO_HANDOVER_WITHOUT_EXCHANGE])

    def test_review_rules(self):
        self.assertTrue(can_review(S.COMPLETED, Actor.BUYER))
        self.assertFalse(can_review(S.COMPLETED, Actor.SELLER))
        self.assertFalse(can_review(S.ACCEPTED, Actor.BUYER))



class PolicyTests(unittest.TestCase):
    def test_self_purchase_blocked(self):
        from orders.domain.policies import SelfPurchaseError, ensure_not_own_shop
        with self.assertRaises(SelfPurchaseError):
            ensure_not_own_shop(buyer_id=5, shop_owner_id=5)
        ensure_not_own_shop(buyer_id=5, shop_owner_id=6)


if __name__ == "__main__":
    unittest.main()