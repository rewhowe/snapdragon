# 金魚草(スナップドラゴン) - snapdragon

[日本語](./README_ja.md)

## Introduction

Let's make a programming language - how hard could it be?

Snapdragon aims to be a simple programming language that, for the most part, reads like normal Japanese.

It takes inspiration from [ひまわり](https://ja.wikipedia.org/wiki/ひまわり_%28プログラミング言語%29) and its deeper, more robust successor [なでしこ](https://ja.wikipedia.org/wiki/なでしこ_%28プログラミング言語%29).

Like ひまわり (sunflower) and なでしこ (carnation), [金魚草](https://ja.wikipedia.org/wiki/キンギョソウ) ([snapdragon](https://en.wikipedia.org/wiki/Antirrhinum)) is named after a type of flower.

To read more about this project, please see the [about](./documentation/about.md) page.

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

6. (Optional) Install vim syntax highlighting
```bash
ln -s ./syntax/sd.vim ~/.vim/syntax/sd.vim
```

## Usage

* See usage information: `./snapdragon --help`

* Example execution: `./snapdragon ./examples/hello_world.sd`

### Writing Snapdragon

* [Documentation / Manual](./documentation/manual/en.md)

* See the examples folder

## Version History

* 2.0.1

  * HOTFIX (assignment to それ/あれ as property owners)

* 2.0.0

  * String Interpolation

  * Associative Arrays

  * Additional Properties (keys, first, last, etc)

  * Additional Built-Ins (formatting, more stack and numeric operations)

  * Improved If-Statements (multiple conditions, empty check, contains check)

  * Improved Loops (multiple condition while, short static loop)

  * Command Line Arguments

  * Try-Catch

  * Additional Math (exponentiation, roots, logarithms)

  * Optional Japanese Command Line Output

* 1.0.0

  * Variables (Number, String, Boolean, Array, それ/あれ)

  * Punctuation (Question, Bang)

  * Functions

  * Comments

  * If-Statements (single conditions)

  * Built-ins (output, basic stack manipulation, basic arithmetic)

  * Loops

  * Properties (Array / String Length)

  * Interpreter
