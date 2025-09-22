# Normalize & SHA256 Hash Variable

A Server-Side Google Tag Manager Variable Template for normalizing and SHA-256 hashing text, email, and phone data for privacy-safe matching.

## Overview

This template normalizes input data (text, email, phone) and generates a SHA-256 hash afterwards. It's specifically designed for Server-Side GTM and supports various data formats for privacy-safe user matching.

## Features

- **Text Normalization**: Trims, converts to lowercase, removes leading/trailing slashes
- **Email Normalization**: Removes Gmail dots and +tags (e.g., `user.name+tag@gmail.com` → `username@gmail.com`)
- **Phone Normalization**: Converts to E.164 format with configurable country code
- **SHA-256 Hashing**: Generates hash in hex or base64 format
- **Auto Detection**: Automatically detects email format based on "@" character

## Configuration

### Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| **Input Value** | Text | The value to normalize and hash | `User.Name+tag@Gmail.com` |
| **Value Format** | Radio | Hash output format | `hex` or `base64` |
| **Data Type** | Select | Type of data to normalize | `email`, `phone`, `name` |
| **Default Country Code** | Text | Default country code for phone numbers | `49` |

### Data Type Options

- **Email**: Gmail normalization (removes dots and +tags)
- **Phone**: E.164 format with country code
- **Name**: Simple text normalization for Name Fields

## Usage

### Email Normalization
```javascript
// Input: "User.Name+Newsletter@Gmail.com"
// normalized: username@gmail.com
// Output (hex): "f7976af5cad49504523379918222f1da1c1e231cd5d0770603c3e71e5e30e030"
```

### Phone Normalization
```javascript
// Input: " 0176-54648789"
// Default Country Code: "49"
// normalized: +4917654648789
// Output (hex): "e45d8b1a608ae4a6ed5c805c2d3c03f0b1195ee333bb2dee4782bf38362e4218"
```

### Text Normalization
```javascript
// Input: "/MaxMustermann/"
// normalized: maxmustermann
// Output (hex): "b5760cb1c9f2ecd81817b9a776592c2390e1058882b08ac91c58fad63c527cd5"
```

## 🔧 Technical Details

### Supported Email Providers
- Gmail/Googlemail (dots and +tags are removed)
- Other providers are treated as regular text

### Phone Formatting
- Automatic detection of country codes (00/+, without prefix)
- Removal of formatting characters (-, spaces, parentheses)
- E.164 format: `+<country code><number>`

### Hash Output
- **Hex**: 64-character hexadecimal string
- **Base64**: URL-safe base64 encoded string

## Tests

The template includes comprehensive tests for all functions:

1. **Email Normalization**: Gmail format with dots and +tags
2. **Phone Normalization**: German numbers in various formats
3. **Text Normalization**: General text cleaning

## Security & Privacy

- **Privacy-Safe**: All data is hashed before use
- **Server-Side Only**: Works only in Server-Side GTM
- **No External Dependencies**: Uses only built-in sGTM functions

## License

This template is licensed under the Apache License 2.0. See `LICENSE` for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push the branch
5. Create a Pull Request

## Support

For questions or issues:
- Create an issue in this repository
- Check the documentation
- Test with different input formats

## Changelog

### v1.0.0
- Initial release
- Email normalization for Gmail
- Phone normalization (E.164)
- Text normalization
- SHA-256 hashing (Hex/Base64)
- Automatic email detection
