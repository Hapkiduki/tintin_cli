
# tintin_cli

A professional Flutter code generator with AI integration.

## Description

`tintin_cli` is a command-line interface (CLI) tool designed to streamline Flutter development through AI-powered code generation. It leverages Mason to create reusable code templates and integrates with the OpenAI API to generate code based on natural language descriptions.

## Features

-   Generate Flutter features using natural language descriptions.
-   Preview code generation with the `--dry-run` option.
-   Utilize Mason for flexible and customizable code templates.
-   Integrate AI for dynamic code generation with OpenAI.
-   Includes pre and post-generation hooks for customization.

## Getting Started

### Prerequisites

-   Flutter SDK installed.
-   Dart SDK installed.
-   Mason CLI installed.
-   OpenAI API key.

### Installation

1.  **Clone the repository:**

    ```bash
    git clone <repository_url>
    cd tintin_cli
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Configure environment variables:**

    -   Create a `.env` file in the root of the project.
    -   Add your OpenAI API key to the `.env` file:

        ```
        OPENAI_API_KEY=YOUR_API_KEY
        ```

    -   Run the build runner to generate the `env.g.dart` file:

        ```bash
        flutter pub run build_runner build --delete-conflicting-outputs
        ```

### Usage

#### Local Execution

1.  **Navigate to the project root:**

    ```bash
    cd tintin_cli
    ```

2.  **Run the CLI with the `generate` command:**

    ```bash
    dart run bin/tintin_cli.dart generate -d "Create a login screen"
    ```

    -   Replace `"Create a login screen"` with your desired feature description.

3.  **Follow the prompts:**

    -   The CLI will prompt you for any required variables.

#### Global Execution

1.  **Activate the package globally:**

    ```bash
    dart pub global activate --source path .
    ```

2.  **Run the CLI from any directory:**

    ```bash
    tintin generate -d "Create a login screen"
    ```

    -   Replace `"Create a login screen"` with your desired feature description.

### Options

-   `-d, --description=<description>`: Feature description for AI generation (required).
-   `--dry-run`: Preview generation without writing files.
-   `-v, --verbose`: Enable verbose logging.

### Example

```bash
tintin generate -d "Create a user profile page"
````

This command will generate the necessary Flutter files for a user profile page based on the provided description.

### Contributing

Contributions are welcome\! Please feel free to submit a pull request or open an issue.

### License

[MIT](https://www.google.com/url?sa=E&source=gmail&q=LICENSE)

### Author

[Hapkiduki](https://github.com/Hapkiduki)

