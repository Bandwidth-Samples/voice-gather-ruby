# Sample App Checklist

## README

 - Is README title correct?
 - Does the README content match that of other sample apps of the same type?
 - Is the correct image in the README and repo?
   - Image should link to product specific Quick Start Guide/About Page
 - All headers should have an empty line above and below
 - All code blocks should have an empty line above and below
 - Does the TOC match the template and rest of README?
 - Is description correct?
   - phone numbers to use in order: +191915551234, +19195554321
   - sample text should be "Hello World!"
   - callbacks should match those in callback section
   - descriptions should match those from other samples of the same feature
   - language specific reference to error catching method
 - Running the Application should have language specific command
 - Environmental Variables should match template order and only include those used in the sample
 - Callback URL Link should link to product specific webhooks page
   - callbacks should match template format
   - callbacks should be ordered: outbound>inbound>others
 - Ngrok section shows language specific port information

## LICENSE

 - Should have MIT LICENSE
 - LICENSE should be up to date with current year

## .gitignore

 - Should contain only language specific files/folders
 - Should match other gitignores for the same language, regardless of usage

## Package Requirement File

 - Should only reference packages required by the specific sample app

## Sample App

 - contains correct imports/requirements
 - environment variables should match the order in the README
 - SDK config and api instances come after imports and envirnmental variables, but before rest of sample app
 - Text responses should resemble sentences and end in periods.
 - Messaging:
    - send/create endpoints come first
        - Messaging:
          - send message endpoint should be `/sendMessage`
          - Should have comment `Make a POST request to this URL to send a text message.`
          - should capture `to` and `text` from incoming post
          - media sent should be `https://cdn2.thecatapi.com/images/MTY3ODIyMQ.jpg`
    - other endpoints should match order listed in README
        - Message Status Callback:
          - Should have comment `This URL handles outbound message status callbacks.`
          - `message-sending` -> `message-sending type is only for MMS.`
          - `message-delivered` -> `Your message has been handed off to the Bandwidth's MMSC network, but has not been confirmed at the downstream carrier.`
          - `message-failed` -> `For MMS and Group Messages, you will only receive this callback if you have enabled delivery receipts on MMS.`
          - `else` -> `Message type does not match endpoint. This endpoint is used for message status callbacks only.`
        - Inbound Message Callback:
          - Should have comment `This URL handles inbound message callbacks.`
          - Should create object based on BandwidthCallbackMessage and  BandwidthMessage models
          - Should print the following in order with newlines in between: callback description, To: "", From: "", Text: ""
          - Media should be created with original media name in root folder of project
          - If the callback type is not `message-received` -> `Message type does not match endpoint. This endpoint is used for inbound messages only.\nOutbound message callbacks should be sent to /callbacks/outbound/messaging.`
        - Auto Response Callback:
          - Should have comment `This URL handles inbound message callbacks.`
          - Should create object based on BandwidthCallbackMessage and  BandwidthMessage models
          - Should print the following in order with newlines in between: callback description, To: "", From: "", Text: ""
          - If the callback type is not `message-received` -> `Message type does not match endpoint. This endpoint is used for inbound messages only.\nOutbound message callbacks should be sent to /callbacks/outbound/messaging.`
          - Response Map should be: 
            - stop: "STOP: OK, you'll no longer receive messages from us.",
            - quit: "QUIT: OK, you'll no longer receive messages from us.",
            - help: "Valid words are: STOP, QUIT, HELP, and INFO. Reply STOP or QUIT to opt out.",
            - info: "INFO: This is the test responder service. Reply STOP or QUIT to opt out.",
            - default: "Please respond with a valid word. Reply HELP for help."
          - Response should have `[Auto Response] ` appended to the front of the message
          - Should print newline, then `Sending Auto Response`, followed by another newline and the sent message in the same format as received message
  - Voice:
      - create call endpoint should be `/createCall`
  - MFA:
      - CLI
        - Phone number prompt should be: `Please enter your phone number in E164 format (+19195551234): ` with a newline before only the first instance
            - input should be validated with regex (`^\+[1-9]\d{4,14}$`) and repeat prompt: `Invalid phone number. Please enter your phone number in E164 format (+19195551234): `
        - Method selection prompt should be: `Please select your MFA method.\nEnter 0 for voice or 1 for messaging: ` with a newline before only the first instance
            - input should be validated using regex (`^[0-1]$`) and repreat promt: `Invalid selection. Enter 0 for voice or 1 for messaging: `
        - Valid/Invalid responses should be `Success!`/`Incorrect Code` respectively

## Language Specific Rules

   - Ruby
      - user created variables should be in snake_case
      - hashes should use symbols as keys

   - Python
      - user created variables should be in snake_case
      - 2 newlines between code blocks
      
   - C#
      - will eventually be renamed to .NET for accuracy
      - Running the Application should include: `Or open the project in Microsoft Visual Studio and run using the button in the toolbar.`