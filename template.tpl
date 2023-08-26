___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Leadfeeder IP-Enrich",
  "description": "Leadfeeder IP-Enrich API allows you to uncover company information related to an IPv4 or IPv6 address.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "apiKey",
    "displayName": "API Key",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "ip",
    "displayName": "IP address",
    "simpleValueType": true,
    "help": "If not set IP then IP address of the request originatator will be used."
  },
  {
    "type": "CHECKBOX",
    "name": "storeResponse",
    "checkboxText": "Store response in cache",
    "simpleValueType": true,
    "help": "Store the response in Template Storage. If all parameters of the request are the same response will be taken from the cache if it exists."
  },
  {
    "type": "CHECKBOX",
    "name": "jsonParseKey",
    "checkboxText": "Extract key from data",
    "simpleValueType": true,
    "subParams": [
      {
        "type": "TEXT",
        "name": "jsonParseKeyName",
        "displayName": "Key Name",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ],
        "enablingConditions": [
          {
            "paramName": "jsonParseKey",
            "paramValue": true,
            "type": "EQUALS"
          }
        ]
      }
    ],
    "help": "For example: company.domain"
  }
]


___SANDBOXED_JS_FOR_SERVER___

const sendHttpRequest = require('sendHttpRequest');
const getRemoteAddress = require('getRemoteAddress');
const encodeUriComponent = require('encodeUriComponent');
const templateDataStorage = require('templateDataStorage');
const getEventData = require('getEventData');
const sha256Sync = require('sha256Sync');
const JSON = require('JSON');


let ip = data.ip ? data.ip : (getEventData('ip_override') ? getEventData('ip_override'): getRemoteAddress());
let url = 'https://api.lf-discover.com/companies?ip='+enc(ip);
let requestOptions = {
    headers: {
        'Accept': 'application/json',
        'User-Agent': 'Stape',
        'X-API-KEY': data.apiKey
    },
    method: 'GET',
    timeout: 10000
};

return sendRequest(url, requestOptions);

function sendRequest(url, requestOptions) {
    let cacheKey = sha256Sync(url + JSON.stringify(requestOptions) + data.jsonParseKeyName);

    if (data.storeResponse) {
        const cachedBody = templateDataStorage.getItemCopy(cacheKey);

        if (cachedBody) return cachedBody;
    }

    return sendHttpRequest(url, requestOptions).then((successResult) => {
        if (successResult.statusCode === 301 || successResult.statusCode === 302) {
            return sendRequest(successResult.headers['location'], requestOptions);
        }

        const parsedBody = JSON.parse(successResult.body);
        const result = data.jsonParseKey ? getByKey(data.jsonParseKeyName, parsedBody) : parsedBody;

        if (data.storeResponse) templateDataStorage.setItemCopy(cacheKey, result);

        return result;
    });
}

function getByKey(keyName, obj) {
    keyName.split('.').reduce(function (p, c) {
        return p && p[c] || null;
    }, obj);
}

function enc(data) {
    data = data || '';
    return encodeUriComponent(data);
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "remoteAddressAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "headersAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_template_storage",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "ip_override"
              }
            ]
          }
        },
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://api.lf-discover.com/*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 26/08/2023, 16:17:12


