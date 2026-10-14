import Foundation

extension LLUser {

    init(customerAccount: CustomerAccount,
         externalId: String,
         email: String) {

        let nameParts = customerAccount.displayName.split(separator: " ", maxSplits: 1)

        self.init(
            id: customerAccount.id,
            firstName: nameParts.first.map(String.init) ?? customerAccount.displayName,
            lastName: nameParts.count > 1 ? String(nameParts[1]) : "",
            email: email,
            externalId: externalId
        )

    }

}
