# WordSmith

WordSmith is a command-line tool for translating words, phrases, and words in context of a sentence.

<img width="524" alt="Screenshot 2024-09-13 at 12 14 05 AM" src="https://github.com/user-attachments/assets/a18514b5-044d-474e-98ad-9cb814ada8e9">

## Features

- Translate single words or phrases
- Translate words within the context of a sentence
- Read words from a file for batch translation
- Optional caching for faster repeated translations
- Specify target language for translations

## Installation

1. Ensure you have Ruby installed on your system (version 2.7 or higher recommended).

2. Install the WordSmith gem:

```
gem install word_smith
```

3. Set up your OpenAI API key and Organization ID:

```
ws --set-openai-api-key YOUR_API_KEY
ws --set-openai-org-id YOUR_ORG_ID
```

Replace `YOUR_API_KEY` and `YOUR_ORG_ID` with your actual OpenAI credentials.

## Usage

Basic usage:

```
ws [word/phrase] [options]
```

Examples:

1. Translate a single word:

```
ws hello
```

2. Translate a phrase:

```
ws good morning
```

3. Translate a word in context:

```
ws a /random/ sentence
```

4. Translate words from a file:

```
ws -f words.txt
```

5. Translate to a specific language:

```
ws hello --target-language Spanish
```

6. Translate without using cache:

```
ws hello --no-cache
```

Options:

- `-f, --file [FILE_PATH]`: Read words from a file
- `--target-language [LANGUAGE_CODE]`: Specify target language for translation
- `--no-cache`: Translate without using cache
- `-h, --help`: Show help
- `-v, --version`: Show version

## Configuration

Set OpenAI API key:

```
ws --set-openai-api-key [key]
```

Set OpenAI Organization ID:

```
ws --set-openai-org-id [key]
```

## License

[Add license information here]
