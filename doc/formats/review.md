The review format is a Markdown-like format with parseable data within.

The general syntax is:

```markdown
# Header

data
```

# Available plugins

The data become parseable when the header matches certain string.

For example when the header is `Expenses`, the {Pomodoro::Formats::Review::Plugins::Expenses} plugin will parse its contents.

Currently available plugins:

- {Pomodoro::Formats::Review::Plugins::Expenses}
- {Pomodoro::Formats::Review::Plugins::Accounts}
- {Pomodoro::Formats::Review::Plugins::MedicalData}
- {Pomodoro::Formats::Review::Plugins::Medications}
- {Pomodoro::Formats::Review::Plugins::Consumption}
