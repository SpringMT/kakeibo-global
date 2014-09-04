# Kakeibo

IAP and IAB receipt validation module.

## Installation

Add this line to your application's Gemfile:

    gem 'kakeibo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kakeibo

## Usage

### iOS
* iOS(IAP in-app-purchase) receipt validation uses Apple receipt validation API.
* iOSのレシート検証はAppleのレシート検証APIを叩くことで行う

```
kakeibo = Kakeibo.new(:Iap, retry_count: 2)
kakeibo.fetch(receipt, transaction_id: SKPaymentTransaction.transactionIdentifier)
kakeibo.valid?
```

#### initialize option
* retry_count
  * If Apple receipt API is down, fetching API retry_count times.
  * Appleのレシート検証APIが落ちていた時の試行回数

### Android
* Android(IAB in-app-billings) receipt validation uses public key from Google Play. DO NOT USE Google API.
* Androidのレシート検証は、Google Playから払い出される公開鍵を使って検証する。GoogleのAPIは使用しない

```
kakeibo = Kakeibo.new(:Iab)
kakeibo.fetch(
  receipt,
  signature: signature,
  base64_encoded_public_key: base64_encoded_public_key,
  developer_payload: developer_payload
)
kakeibo.valid?
kakeibo.order_id # You should validate order_id uniqueness for security
```

#### for sucurity
* Please See [this pages](http://developer.android.com/training/in-app-billing/purchase-iab-products.html) security recommendation!
    * You should verify that the orderId is a unique value that you have not previously processed, and the developerPayload string matches the token that you sent previously with the purchase request.
    * orderIdはユニーク性の担保をしてください。developerPayloadを使って、必ずrequestの整合性チェックを行って下さい

## Refernces

### iOS
* [レシート検証プログラミングガイド](https://developer.apple.com/jp/devcenter/ios/library/documentation/ValidateAppStoreReceipt.pdf)
* [In-App Purchaseプログラミングガイド](https://developer.apple.com/jp/devcenter/ios/library/documentation/StoreKitGuide.pdf)
* [SKPaymentTransaction](https://developer.apple.com/library/prerelease/mac/documentation/StoreKit/Reference/SKPaymentTransaction_Class/)

### Android
* [Google Play In-app Billing](http://developer.android.com/google/play/billing/index.html)
* [Purchasing In-app Billing Products](http://developer.android.com/training/in-app-billing/purchase-iab-products.html)
* [Security Best Practices](http://developer.android.com/google/play/billing/billing_best_practices.html)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/kakeibo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
