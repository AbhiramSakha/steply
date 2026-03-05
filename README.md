# Steply
Steply is a CLI tool to validate APIs, databases, Kafka messages, and more.

- You can automate BDD-style tests or run manual validations without writing code, using simple JSON or YAML test steps.

- Store tests in Git(never loose your tests again) and easily manage manual tests, regression suites, and complex integration tests.

## Install
```shell
curl -fsSL https://raw.githubusercontent.com/QABEES/steply/main/scripts/install.sh | bash
```

## Run a test
```shell
steply --scenario tests/validate_github_user.json --target-env env/sit.properties
```

## Run a full test suite:
```
steply --folder tests --target env/sit.properties
```

Project Folder Structure:
```
my-integration-testing-project/
├── env
│   ├── sit.properties
│   ├── pre_prod.properties
│   └── github_host.properties
└── tests
   ├── validate_github_user_api.json
   ├── validate_create_user_api.json
   └── validate_update_emplyee_api.json

OUTPUT:
-------
├── target/
│   ├── logs
│   │   └── executions.log
│   ├── test-report.csv
│   ├── test-interactive-report.html
```

Testcase Example:

JSON
```json
  {
    "name": "call_pcdp_api",
    "url": "https://api.github.com/users/octocat",
    "method": "GET",
    "request": {
      "headers": {
        "Content-Type": "application/json"
      }
    },
    "verify": {
      "status": 200
    }
  }
```

or

YAML
```yaml
- name: call_pcdp_api
  url: https://api.github.com/users/octocat
  method: GET
  request:
    headers:
      Content-Type: application/json
  verify:
    status: 200
```

## Exit Codes (CI Friendly)

Steply returns(for the example above):
- 0 → HTTP 200 OK
- Non-zero → Any other response

This makes it easy to use in CI pipelines to determine build status.

## Authentication
The Authorization header can be automatically populated using a token from an authentication server.


## CLI Help
```shell
➜  steply -h

or

➜  steply --help 
```

## Reports & Logs
After execution, reports are generated in the "target/" folder:
- HTML interactive report
- CSV report
- Execution logs (see "target/logs/" folder)

## Notes
- --target and --target-env work the same way.
- Short forms like --targ are also accepted.

## Alternative to
- Postman
- Insomnia
- Karate

but with modern, opensource, lightweight, secure and CLI appraoch, providing easily pluggable cloud integrations. 

While the above tools are powerful, they are often heavy, proprietary, or tightly coupled to specific language ecosystems(such as Java, Groovy etc).

- This project is designed as a modern alternative to popular API development tools.

- And focuses on providing a open-source and collaborative developer/SDET experience with easily pluggable hooks to external tools(such as Kafka, S3, Postgres etc).

## Credits
Special thanks to all the authors and contributors of the zerocode-tdd JSON/YAML testing framework.

## Documentation
For detailed documentation and examples, visit [here](https://zerocode-tdd.tddfy.com/) 

As you are using the Steply CLI, you can ignore the Maven/Java sections in the documentation.
