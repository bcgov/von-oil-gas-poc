# Verifying a Proof with OrgBook

## Pre-requisites

To complete the proof verification process, an agent and the related controller are required.

For the agent to be able top start correctly, its DID will need to be registered on the ledger. This is a process that can be done ahead of time and, as long as the agent's seed/DID don't change, it won't be necessary to complete this task again.

- Choose a 32 character seed for your agent, and use it to register on the target ledger. The landing page for the ledger browser will provide a UI to complete the task. Upon successful registration, your agent's DID and verkey will be returned.

When starting-up an agent, a number of command-line parameters are required in order to automate some of the tasks that would otherwise require user interaction when establishing connections, requesting proofs, etc.
Please refer to aries-cloudagent-python (run `python aca-py --help` to discover the available options.

A set of commonly used parameters can be seen [here](https://github.com/bcgov/indy-catalyst-issuer-controller/blob/master/docker/docker-compose.yml#L103-L125).

## Retrieving Credentials

Use the [OrgBook API](https://orgbook-dev.pathfinder.gov.bc.ca/api/) to retrieve the credentials that will require verification.

## Connecting to the OrgBook Agent

This is an off-band process, and will require someone from the OrgBook team to provide an invitation request. The invitation request will be posted to the agent admin interface to the `/connections/receive-invitation` endpoint.
The agent will automatically create and activate the connection with OrgBook, provided that the correct startup parameters were set when starting the agent.

### Requesting a Proof

1. Using the attributes fetched from OrgBook, build proof structured like the following JSON. Once ready, execute a POST request to the `/present-proof/send-request` endpoint on the agent admin interface, including the JSON in the body

```javascript
{
  "connection_id": "d1408ad1-98ba-4a72-b54a-498f364c039f",
  "proof_request": {
    "version": "1.0",
    "name": "proof-request",
    "requested_predicates": [{}],
    "requested_attributes": [
      {
        "requestedAttr1": {
          "name": "corp_num",
          "restrictions": [
            {
              "issuer_did": "52Po5igEeRhtGHVs8Qmhow",
              "schema_version": "1.0.0",
              "schema_name": "my-registration.emiliano-garage",
              "attr::corp_num::value": "ABC12345"
            }
          ]
        }
      }
    ]
  }
}
```

2. If successful, the response body will contain a JSON object that includes the "presentation_exchange_id" generated for this transaction:

```
{
  "state": "request_sent",
  "created_at": "2019-10-10 22:05:15.603463Z",
  "initiator": "self",
  "auto_present": false,
  "presentation_exchange_id": "bac7e7b0-7db4-4a86-8e22-9b6f6d999a36",
  "connection_id": "d1408ad1-98ba-4a72-b54a-498f364c039f",
  "presentation_request": {
    "version": "1.0",
    "name": "self-verify",
    "nonce": "319540542544657147044505520631103047756",
    "requested_predicates": {},
    "requested_attributes": {
      "6b71fefd-5e59-462b-a11c-9dc39d72c81a": {
        "name": "corp_num",
        "restrictions": [
          {
            "issuer_did": "52Po5igEeRhtGHVs8Qmhow",
            "schema_version": "1.0.0",
            "schema_name": "my-registration.emiliano-garage",
            "attr::corp_num::value": "ABC12345"
          }
        ]
      }
    }
  },
  "updated_at": "2019-10-10 22:05:15.603463Z",
  "thread_id": "a082f533-333b-452e-a35a-77a2ec221ba5"
}
```

3. Wait a few seconds to let the agents communicate and sync, then use the `presentation_exchange_id` to call the `/present-proof/records/{pres_ex_id}` endpoint on the agent admin interface. The presentation exchange state should be "verified", as we will probably have started the agent using the `--auto-verify-presentation` flag. If the state is "presentation_received" it could be either because:

- we have not started the agent with the `--auto-verify-presentation` flag: we will then need to use the same `presentation_exchange_id` and call the `/present-proof/records/{pres_ex_id}/verify-presentation` endpoint on the agent admin interface to complete the cyptographic verification of the credential.

- we are sending a presentation request that contains more than one restriction on attribute values: this will currently fail due to a bug in [indy-sdk](https://github.com/hyperledger/indy-sdk/pull/1893).
