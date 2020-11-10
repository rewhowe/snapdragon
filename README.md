# 金魚草(スナップドラゴン) - snapdragon

[日本語](./documentation/README_jp.md)

## Introduction

Let's make a programming language - how hard could it be?

Snapdragon aims to be a simple programming language that, for the most part, reads like normal Japanese.

It takes inspiration from [ひまわり](https://ja.wikipedia.org/wiki/ひまわり_%28プログラミング言語%29) and its deeper, more robust successor [なでしこ](https://ja.wikipedia.org/wiki/なでしこ_%28プログラミング言語%29).

Like ひまわり (sunflower) and なでしこ (carnation), [金魚草](https://ja.wikipedia.org/wiki/キンギョソウ) ([snapdragon](https://en.wikipedia.org/wiki/Antirrhinum)) is named after a type of flower.

## Setup

1. Install [rbenv](https://github.com/rbenv/rbenv#installation).
```bash
rbenv local
# should be 2.3.0
```

2. Install [bundler](https://bundler.io):
```bash
gem install bundler
```

3. Install required gems:
```bash
bundle install
```

4. Confirm executable:
```bash
./snapdragon -v
```

5. Run the tests (from the root directory):
```bash
rspec
```

## Usage

* See usage information: `./snapdragon --help`

### Writing Snapdragon

* [Documentation / Manual](./documentation/manual.md)

* See the examples folder

## Version History

* 1.1.0 (planned)

  * Additional Built-Ins (formatting, index retrieval, more stack manipulation)

  * String Interpolation

  * If-Statements (multiple conditions)

  * Associative Arrays

  * Command Line Arguments

  * Additional Math (exponentiation, roots, logarithms)

  * Try-Catch

* 1.0.0 (in progress)

  * Variables (Number, String, Boolean, Array, それ/あれ)

  * Punctuation (Question, Bang)

  * Functions

  * Comments

  * If-Statements (single conditions)

  * Built-ins (output, basic stack manipulation, basic arithmetic)

  * Loops

  * Properties (Array / String Length)

  * Interpreter
