___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Normalize \u0026 SHA256 Hash",
  "description": "Server-Side GTM variable: trims \u0026 lowercases input, normalizes Gmail and phone (E.164), strips slashes, then returns SHA-256 hash in hex or base64 for privacy-safe matching.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "input",
    "displayName": "Input Value",
    "simpleValueType": true
  },
  {
    "type": "RADIO",
    "name": "encoding",
    "displayName": "Value Format",
    "radioItems": [
      {
        "value": "base64",
        "displayValue": "Base 64"
      },
      {
        "value": "hex",
        "displayValue": "Hex"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "SELECT",
    "name": "type",
    "displayName": "What type of data has to be normalized",
    "macrosInSelect": true,
    "selectItems": [
      {
        "value": "email",
        "displayValue": "Email"
      },
      {
        "value": "phone",
        "displayValue": "Phone"
      },
      {
        "value": "name",
        "displayValue": "Name"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "defaultCountryCode",
    "displayName": "Default Country Code",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

const log = require('logToConsole');
const sha256Sync = require('sha256Sync');
const createRegex = require('createRegex');

const rawInput = data.input;
if (rawInput === undefined || rawInput === null) {
  return undefined;
}
const input = (rawInput || '') + '';
if(input ==="" || input === null || input === undefined) return undefined;

const encoding = (data.encoding || 'hex') + '';
const type = (data.type || 'text') + '';
const defaultCC = (data.defaultCountryCode || '') + '';

// Regex
const RE_NON_DIGIT_PLUS = createRegex('[^\\d+]', 'g');
const RE_NON_DIGIT      = createRegex('\\D', 'g');
const RE_LEADING_ZEROES = createRegex('^0+');
const RE_EDGE_SLASHES   = createRegex('^/+|/+$', 'g');

// Helpers
function toLowerTrimAndStripEdges(s) {
  s = (s || '') + '';
  s = s.trim().toLowerCase();
  s = s.replace(RE_EDGE_SLASHES, ''); // "/foo@" -> "foo@"
  return s;
}
function keepDigitsPlus(s){ return ((s||'')+'').replace(RE_NON_DIGIT_PLUS,''); }
function keepDigits(s){ return ((s||'')+'').replace(RE_NON_DIGIT,''); }
function stripLeadingZeros(s){ return ((s||'')+'').replace(RE_LEADING_ZEROES,''); }

// Normalisierung Text
function normalizeText(s) {
  return toLowerTrimAndStripEdges(s);
}

// Normalisierung Email (Gmail-Dots & +Tag entfernen)
function normalizeEmail(email) {
  email = toLowerTrimAndStripEdges(email);
  const parts = email.split('@');
  if (parts.length !== 2) return email;

  let local = parts[0];
  let domain = parts[1];

  if (domain === 'gmail.com' || domain === 'googlemail.com') {
    const plusIdx = local.indexOf('+');
    if (plusIdx !== -1) local = local.substring(0, plusIdx);
    // Alle Punkte im Local-Part entfernen
    local = local.split('.').join('');
    domain = 'gmail.com';
    const out = local + '@' + domain;
    log('gmail normalized local:', local);
    return out;
  }
  return email;
}

// Telefon → E.164 (heuristisch)
function toE164(phoneRaw, cc) {
  if (!phoneRaw) return '';
  let s = toLowerTrimAndStripEdges(phoneRaw);
  s = keepDigitsPlus(s);

  if (s.indexOf('00') === 0) s = '+' + s.substring(2);
  if (s.indexOf('+') === 0) return '+' + keepDigits(s.substring(1));

  const cleanCC = keepDigits(cc || '');
  if (!cleanCC) return keepDigits(s);

  s = stripLeadingZeros(s);
  return '+' + cleanCC + keepDigits(s);
}

// ---- Routing (robuster Email-Fallback bei "@") ----
let normal;
const looksLikeEmail = input.indexOf('@') !== -1;

if (type === 'email' || looksLikeEmail) {
  normal = normalizeEmail(input);
} else if (type === 'phone') {
  normal = toE164(input, defaultCC);
} else {
  normal = normalizeText(input);
}

log('input:', input);
log('normalized:', normal);

// Hash nach Normalisierung
const digestBase64 = sha256Sync(normal);
const digestHex = sha256Sync(normal, { outputEncoding: 'hex' });

return encoding === 'base64' ? digestBase64 : digestHex;


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
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

scenarios:
- name: ipnut is email
  code: |-
    const mockData = {
      input: "user.Name+foo@gmail.com",
      encoding: "hex",
      type: "name",
      defaultCountryCode : "49"
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: input is phone
  code: |-
    const mockData = {
      input: " 0176-54648789",
      encoding: "hex",
      type: "phone",
      defaultCountryCode : "49"
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: input is name
  code: |-
    const mockData = {
      input: "/MaxMustermann/",
      encoding: "hex",
      type: "name",
      defaultCountryCode : "49"
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
setup: ''


___NOTES___

Created on 22.9.2025, 10:14:49


