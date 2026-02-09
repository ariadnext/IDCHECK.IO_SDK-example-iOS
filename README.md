![IDnow Logo](img/idcheck_logo.png)

> ℹ️ For older IDCheckIOSDK sample (v8.x.x), please checkout the [sdk_v8](https://github.com/ariadnext/IDCHECK.IO_SDK-example-iOS/tree/sdk_v8) branch.<br>
> ℹ️ For older IDCheckIOSDK sample (v7.x.x), please checkout the [sdk_v7](https://github.com/ariadnext/IDCHECK.IO_SDK-example-iOS/tree/sdk_v7) branch.

# IDCheck.io Mobile SDK Sample for iOS

[![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg)](https://developer.apple.com/ios/)
[![iOS](https://img.shields.io/badge/iOS-14.0-blue.svg)](https://developer.apple.com/swift/)

## Requirements

* **Xcode:** version 26.0 or higher.
* **Deployment target:** iOS 14 or later.

## Getting Started

To start an IDCheck.io flow, you need to complete several steps.

### Step 1: Add dependency

To get this sample running, please follow the instructions :

First, to be able to fetch IDCheckIOSDK, you need to have a `.netrc` file with your credentials given by our team to let SPM authenticate through our Nexus repository.
Just create a `.netrc` file in the root directory of your user and add the following lines :

```
machine repoman.rennes.ariadnext.com
login YOUR_LOGIN
password YOUR_PASSWORD
```

Then add dependency in your project with Swift Package Manager. The SPM repo link is [here](https://git-externe.rennes.ariadnext.com/idcheckio/idcheckiosdk-release-ios.git). You can choose the version by tag or take the master branche to get the latest release.

#### Camera
To be fully operational, the IDcheckio Mobile SDK needs to have access to camera and NFC Reader. In your application’s `Info.plist`, add these entries (if not already present):

```(xml)
<key>NSCameraUsageDescription</key>
<string>ENTER YOUR CAMERA DESCRIPTION HERE</string>
```

**Liveness specific Settings**

In order to have the best color-matching results during liveness sessions, please add the following in your application’s `Info.plist` :
```(xml)
<key>UIWhitePointAdaptivityStyle</key>
<string>UIWhitePointAdaptivityStylePhoto</string>
```
This setting will reduce the TrueTone white color shift when activated.

#### NFC

If you will be using NFC for emrtd sessions, also add this entry to your application’s `Info.plist` to specify application identifiers that your app supports :

```(xml)
<key>NFCReaderUsageDescription</key>
<string>ENTER YOUR NFC DESCRIPTION HERE</string>

<key>com.apple.developer.nfc.readersession.iso7816.selectidentifiers</key>
<array>
    <string>A0000002471001</string>
    <string>A0000002472001</string>
    <string>00000000000000</string>
</array>
```
To use NFC, you also need to add this to your application’s `entitlements` file:
```
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
    <string>TAG</string>
    <string>PACE</string>
</array>
```
And don’t forget to add the `Near Field Communication` Tag Reading capability in your Xcode project to enable your app to read tags.

### Step 2: Preload
> The preload method is no longer mandatory now that phones are becoming increasingly powerful.

To ensure a proper startup of the SDK, it is recommended to launch the preload method as early as possible before starting a session.

```(swift)
Idcheckio.preload(extractData: true)
```

### Step 3: Activate the SDK
To activate the SDK, you'll need an authentication token, it will be provided to you by the **Customer Success Management (CSM)** team. Use this token to initialize the SDK in your application.
To do so, you need to call the activate as soon as you enter your onboarding (to avoid having to wait for it to finish).

You can personalize the appearance of the SDK user interface by passing a custom font during activation. This is done by using the optional font parameter in the activate(withToken:extractData:font:) method.

```(swift)
let headingFont = UIFont(name: "YOUR_HEADING_FONT", size: UIFont.systemFontSize)
let regularFont = UIFont(name: "YOUR_REGULAR_FONT", size: UIFont.systemFontSize)
let mediumFullFont = UIFont(name: "YOUR_MEDIUM_FONT", size: UIFont.systemFontSize)
let font: CustomFont? = CustomFont(heading: headingFont, regularContent: regularFont, mediumContent: mediumFullFont)
do {
    try await Idcheckio.activate(withToken: ClientEnvironment.current.token, extractData: true, font: font)
    print("Initialization successed !")
} catch {
    print("Error occured on activation : \(error.localizedDescription)")
}
```

### Step 4: Start a session
#### Use Onboarding Mode (Recommended)
Onboarding mode will simplify the integration of the sdk by handling all the configuration on the server side. With onboarding mode, there's no need to manually start multiple online sessions to capture several documents unlike the online mode (for example, ID session followed by bioliveness session). Once the server-side configuration is complete, simply start the onboarding environment, and all your sessions will launch automatically, one after the other.

CSM team will assist you in setting up this journey according to your specific needs.

When onboarding is started, all customization is retrieved from the server and automatically applied without any action required on the mobile side. 

The CSM team will create the theme in your company's style with you. 

To start an onboarding you just need to call the startOnboarding method on the Idcheckio object.
```(swift)
do {
    try await Idcheckio.startOnboarding(with: folderUid)
} catch {
    print("Error occured : \(error)")
}
```

#### Use Online Mode (Deprecated)
> This mode will be deprecated in a future version.

It’s not recommended to use this mode except if you are already using it or if you have special needs that can not be achieved with the dynamic onboarding. Before using this integration mode speak about your issues with your CSM.

To configure a capture session, you have to set capture parameters .

To configure a session, you have to pass an `SDKParams` and an `SDKExtraParams`. These objects will contain every information related to the session you want to perform.
Most of the parameters are optional, the only mandatory parameter needed to start a session is the document type.

As the sdk do the capture one by one and didn't have information on the previous captures, we created an `OnlineContext` object which is used by the sdk to store data and conserve them between capture. To make it works on your flow, for the first capture you can call start a session without providing an onlineContext. And for all the following capture you just need to pass the onlineContext that the sdk gave you in the last result.

```(swift)
do {
  let sdkParams = SDKParams()
  // Set your custom session parameters
  let extraParams = SDKExtraParams()
  // Set your custom session extra parameters
  let result = try await Idcheckio.startSession(onlineContext: onlineContext, sdkParams: sdkParams, sdkExtraParams: extraParams)
  print("Session ended successfully with result : \(result)")
  [...]
} catch {
    print("Error occured : \(error)")
}

```

The `OnlineContext` is an object, deeply linked to online mode of the SDK, used to communicate with the CIS API in order to send some context with the scanned document. This object cannot been instantiated, it is returned by the SDK on previous online captures in the `IdcheckioResult` object. It makes scanning multiple documents easier by keeping track of the CIS online context and reference document in case of Biometric Liveness session. All the parameters are optional and `nil` by default. As mentioned, its three first attributes are used to specify the folder unique identifier, the reference document and associated check task identifiers :
- `folderUid`: the CIS folder UID on which document have been uploaded
- `taskUid`: the CIS analyze task UID of the document that has been uploaded
- `documentUid`: the CIS document UID of the document that has been uploaded
- `referenceTaskUid`: the eventual CIS reference analyze task UID (provided only if isReferenceDocument has been set to true on OnlineConfig param),
- `referenceDocUid`: the eventual CIS reference document UID (provided only if isReferenceDocument has been set to true on OnlineConfig param),
- `livenessStatus`: tells if the CIS folder contains a valid identity document permitting to start a liveness session. (provided only if isReferenceDocument has been set to true on OnlineConfig param)

> In order to launch a biometric liveness session, you first need to provide a valid identity document (containing a face which will be used as reference for the facematch algorithm). This document will serve as the reference document for the facematching of the liveness session. Don’t forget to set `isReferenceDoc` to `true` on OnlineConfig param.

IDCheck.io Mobile SDK provides you multiple parameters to custom its behavior and configure your session properly.

##### SDKParams
| Field | Type | Description | Default value |
| --- | ---  | --- | --- |
| documentType | DocumentType | Specify which document type the SDK should find | DISABLED |
| integrityCheck | IntegrityCheck | Determines whether the SDK should check document integrity. Two parameters possible : <br>- readEmrtd : Will read the NFC chip if present.<br>- docLiveness : Will take a live video if the document moving to analyse security features. | Both false. |
| orientation | Orientation | Set interface orientation PORTRAIT, LANDSCAPE or AUTOMATIC | Automatic |
| onlineConfig | OnlineConfig | Set CIS specific configuration | See OnlineConfig documentation |
| captureMode | CaptureMode | Give the possibility to choose between the upload and the capture of a document | CAMERA |

##### DocumentType
| Type | Description |
| --- | ---  |
| DISABLED | No document detection specified. This means that SDK will try to detect any document type. |
| ID | ID document detection. |
| VEHICLE_REGISTRATION | Vehicle registration detection. |
| A4 | Detection of any A4 document type. |
| FRENCH_HEALTH_CARD | French Health Card (Both 1997 and 2007 models). |
| BANK_CHECK | Bank check document detection. |
| OLD_DL_FR | Old french driving license document detection. |
| SELFIE | Selfie for face recognition. |
| LIVENESS | Liveness session. |
| PHOTO | Take a photo of any document. The SDK will try to detect any document type. |

##### OnlineConfig
| Field | Type | Description | values | Default value |
| --- | ---  | --- | --- | --- |
| isReferenceDocument| Boolean| Specifies if the document will be a reference for a biometric liveness. | true / false | false |
| cisType | CISType | Associated CIS DocumentType to upload. Please always provide a value for this property if the associated document comes from a A4 scanning session. NOTE: The OTHER CISType will add your image as an attachment in the cis folder and it won’t be analyzed. | ID, IBAN, CHEQUE, TAX_SHEET, PAY_SLIP, ADDRESS_PROOF, CREDIT_CARD, PORTRAIT, LEGAL_ENTITY, CAR_REGISTRATION, LIVENESS, OTHER | nil |
| folderUid | String | If you have already created a folder in the CIS apart of the SDK, please provide its UID here. Else let this value at nil, the SDK will create a folder by itself and return its UID in OnlineContext object. | nil | 
| biometricConsent | Boolean | Allows you to force the biometric consent in case you already asked it to the user (consent regarding automatic processing of his biometric data). If you didn’t already asked the final user his consent (i.e if biometricConsent is null), the SDK will display a popup before starting a liveness or selfie capture. | true / false / nil | nil |
| enableManualAnalysis | Boolean | The document will be automatically be sent to Manual Analysis where a human operator will check it manually and give a verdict. | true / false | false  |
|cisDocCheckLaunch | Boolean | Allow you to disable the document analysis at the end of the capture is you need it, or if you want to call it by yourself later. | true / false | true  |

##### CaptureMode
| Type | Description |
| --- | ---  |
| CAMERA | Use the camera to capture the document. |
| PROMPT | Show a page to let the user choose between uploading his document or capturing it. |
| UPLOAD | Ask the user to upload his document. |

##### SDKExtraParams
| Field | Type | Description | Default value |
| --- | ---  | --- | --- |
| language | Enum | Optional - Force the SDK language. More details in the specific Language section. | nil |
| adjustCrop | Boolean | Allow end-user to adjust the detected document crop. | false |
| manualButtonTimer | Integer | Timeout after which the manual photo button appears. To disable the manual button display, set this value to -1 | 10 |

##### Language
| Type | Description |
| --- | ---  |
| sq | Albanian |
| ar | Arabic |
| ca | Catalan |
| cs | Czech |
| nl | Dutch |
| en | English |
| fr | French |
| de | German |
| el | Greek |
| hu | Hungarian |
| it | Italian |
| pl | Polish |
| pt | Portuguese |
| ro | Romanian |
| ru | Russian |
| sr | Serbian |
| sk | Slovak |
| es | Spanish |
| uk | Ukrainian |

#### Handling errors
For the error case, you will have to cast the error to an `IdcheckioError` object.
```(swift)
IdcheckioError(var cause: Cause, var subcause: Subcause?, var details: String, var message: String?)
```
The object is structured as follow:
- The first parameter, `cause`, is an enumeration listing the main category, or cause of the error.
- The second parameter, `details`, is a detailed error message for more details (like CIS error message) on the error to help you debug on what happened.
- The third parameter, `message`, is an optional error message that can be displayed to the final user.
- The last parameter, `subCause`, is an optional enumeration listing a subset of specific error causes that you can use to inform the user about what went wrong, restart the capture or trigger a new capture from within your application.

> The error details is for debug purpose only and should not be displayed as it is to the end user (this message is not translated by the way).

You should first check the subCause, it’s a custom enumeration that’s we created to have a filter of the error you can handle at runtime. 
If the subCause is empty then you can look at the main cause which is quite generic.
If you receive one of those subCause, it means that we already did the maximum capture retries and the user still failed to complete the capture.

```(swift)
public enum Subcause: String, Codable {
    /// Missing permissions, permissions have been refused by user
    case missingPermission = "MISSING_PERMISSION"
    /// Onboarding session have been cancelled by user
    case cancelledByUser = "CANCELLED_BY_USER"
    /// The document is not eligible for a PVID session.
    case pvidNotEligible = "PVID_NOT_ELIGIBLE"
    /// This model of document cannot be used as it was rejected by configuration.
    case modelRejected = "MODEL_REJECTED"
    /// The document is expired.
    case analysisExpiredDoc = "ANALYSIS_EXPIRED_DOC"
    /// We failed to identified the document
    case unidentified = "UNIDENTIFIED"
    /// The document does not contain a face and can't be used for face recognition
    case docNotUsableFaceRec = "DOC_NOT_USABLE_FACEREC"
    /// The document uploaded is not supported.
    case unsupportedFileExtension = "UNSUPPORTED_FILE_EXTENSION"
}
```

If you want to handle generic errors, you can use the main error cause :
```(swift)
public enum Cause: String, Codable {
    /// Regroup all the integration errors. If you need to understand what you are doing wrong, please contact the CSM team with the details.
    case customerError = "CUSTOMER_ERROR"
    /// Regroup all the network errors that happens when the SDK fails to reach our server.
    case networkError = "NETWORK_ERROR"
    /// The user has done something wrong during the capture.
    case userError = "USER_ERROR"
    /// Internal server error from our side.
    case internalError = "INTERNAL_ERROR"
    /// Regroup all the hardware/software problems that could happen during the session.
    case deviceError = "DEVICE_ERROR"
    /// The document shown by the user is not acceptable. (Expired, rejected, ...)
    case documentError = "DOCUMENT_ERROR"
}
```

### Step 5: Get the result
A session will be "stopped" by two ways:
- The session ended by itself.
- The user aborted the session by pressing the "back" button.

In both cases, you’ll be notified. If the user aborted the session via the back button, you’ll get the specific `.cancelledByUser`.

> Do not call `stop()` by yourself, unless you have a specific need (for example, overriding the back button command).

When the SDK matches with a document, results are sent back as an `IdcheckioResult` object. It contains :
- `onlineContext`: Informations related to the document, need to be passed to the next capture. You can also retrieve the informations related to the created document on the CIS here such as documentUid and folderUid.
- `sessionInfos`: a list of IdcheckioError (non fatal errors) that occurred during the session. It is mainly used with the emrtd reading to tell why the emrtd session have not been done (for example if there if there is no chip on the document)
- `images`: list of all the images taken during the capture.



## Sample application
​
This sample project aims to showcase all possibilities of the **IDCheck.io Mobile SDK** and the associated best practices regarding these features. It also helps you understand how you can easily integrate the SDK, activate it and customise/adapt it to your application and business needs.
​
The main screen displays two buttons to choose between distinct capture flows :
​
 - **Online flow** : This flow uses the SDK for starting one session to capture only one document. You can configure wich type of document you want to capture with recommended configurations indicated in the *SDKConfig.swift* file.
 - **Onboarding flow** (**Recommended**) : This is a flow that allows you to chain several sessions (for example identity document + bioliveness). To configure the session you must contact [Customer Success Managers](mailto:csm@idnow.com).
​
Select the flow you want to try to start capturing documents with the SDK.
