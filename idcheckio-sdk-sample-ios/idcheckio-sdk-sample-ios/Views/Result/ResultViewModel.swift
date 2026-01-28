//
//  ResultViewModel.swift
//  idcheckio-sdk-sample-ios
//
//  Created by Nabil LAHLOU on 31/10/2025.
//

import IDCheckIOSDK

/// View model of the result view
class ResultViewModel {
    // MARK: - Properties
    var result: IdcheckioResult?

    var resultEntries: [ResultEntry] {
        switch result?.document {
        case .identity(let idDocument):
            let documentFields = idDocument.fields.sorted { $0.key.rawValue < $1.key.rawValue }
            let keys = documentFields.map{ $0.key }
            let fields = documentFields.map { $0.value }
            var resultEntries = keys.indices.map { index in
                ResultEntry(title: keys[index].rawValue, value: fields[index].value ?? "")
            }
            resultEntries.removeAll(where: {$0.title == IdentityDocument.Fields.codeLine.rawValue})
            return resultEntries
        case .vehicleRegistration(let registrationDocument):
            let documentFields = registrationDocument.fields.sorted { $0.key.rawValue < $1.key.rawValue }
            let keys = documentFields.map{ $0.key }
            let fields = documentFields.map { $0.value }
            return keys.indices.map { index in
                ResultEntry(title: keys[index].rawValue, value: fields[index].value ?? "")
            }
        default:
            return []
        }
    }

    // MARK: - Init
    init(result: IdcheckioResult?) {
        self.result = result
    }
}
