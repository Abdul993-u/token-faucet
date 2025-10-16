;; title: token-faucet
;; version: 1.0
;; summary: STX Token Faucet with 24-hour claim limit
;; description: Users can claim STX rewards once per 24 hours. Owner can manage faucet.

;; ------------------------------------------------------------
;; Token Faucet - Error-Free Version
;; ------------------------------------------------------------
;; Built with Clarity for the Stacks Blockchain
;; Users can claim STX rewards once per 24 hours
;; Owner can refill faucet, change reward, and withdraw funds
;; Includes full error handling and read-only view functions
;; ------------------------------------------------------------

;; ------------------------------------------------------------
;; DATA DEFINITIONS
;; ------------------------------------------------------------

(define-data-var faucet-balance uint u0)
(define-data-var reward-amount uint u10000000)
(define-data-var owner principal tx-sender)
(define-map last-claim ((user principal)) ((timestamp uint)))

;; ------------------------------------------------------------
;; ERROR CODES
;; ------------------------------------------------------------

(define-constant ERR-NO-BALANCE (err u100))
(define-constant ERR-ALREADY-CLAIMED (err u101))
(define-constant ERR-NOT-OWNER (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-TRANSFER-FAILED (err u104))
(define-constant ERR-NO-CLAIM-FOUND (err u105))

;; ------------------------------------------------------------
;; ADMIN FUNCTIONS
;; ------------------------------------------------------------

;; Deposit STX into the faucet (owner only)
(define-public (refill (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-OWNER)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set faucet-balance (+ (var-get faucet-balance) amount))
    (ok (var-get faucet-balance))
  )
)

;; Withdraw all remaining STX from faucet (owner only)
(define-public (owner-withdraw (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-OWNER)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (<= amount (var-get faucet-balance)) ERR-NO-BALANCE)
    (try! (as-contract (stx-transfer? amount tx-sender (var-get owner))))
    (var-set faucet-balance (- (var-get faucet-balance) amount))
    (ok { withdrawn: amount, remaining: (var-get faucet-balance) })
  )
)

;; Update the reward per claim (owner only)
(define-public (set-reward (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-OWNER)
    (asserts! (> new-amount u0) ERR-INVALID-AMOUNT)
    (var-set reward-amount new-amount)
    (ok new-amount)
  )
)

;; Transfer ownership to another principal
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-OWNER)
    (var-set owner new-owner)
    (ok new-owner)
  )
)

;; ------------------------------------------------------------
;; USER FUNCTION
;; ------------------------------------------------------------

(define-public (claim)
  (let
    (
      (reward (var-get reward-amount))
      (balance (var-get faucet-balance))
      (now block-height)
      (last (default-to u0 (get timestamp (map-get? last-claim { user: tx-sender }))))
    )
    (begin
      (asserts! (>= balance reward) ERR-NO-BALANCE)
      ;; ensure 24-hour delay = ~144 blocks (6 blocks/hour)
      (asserts! (>= (- now last) u144) ERR-ALREADY-CLAIMED)
      (try! (as-contract (stx-transfer? reward tx-sender (var-get owner))))
      (var-set faucet-balance (- balance reward))
      (map-set last-claim { user: tx-sender } { timestamp: now })
      (ok { user: tx-sender, claimed: reward, remaining: (var-get faucet-balance) })
    )
  )
)

;; ------------------------------------------------------------
;; READ-ONLY FUNCTIONS
;; ------------------------------------------------------------

(define-read-only (get-faucet-balance)
  (ok (var-get faucet-balance))
)

(define-read-only (get-reward-amount)
  (ok (var-get reward-amount))
)

(define-read-only (get-last-claim (user principal))
  (ok (default-to u0 (get timestamp (map-get? last-claim { user: user }))))
)

(define-read-only (get-owner)
  (ok (var-get owner))
)

(define-read-only (get-next-claim-block (user principal))
  (let
    (
      (last (default-to u0 (get timestamp (map-get? last-claim { user: user }))))
    )
    (ok (+ last u144))
  )
)
