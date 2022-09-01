# Reflect Agent

[Reflect](https://reflect.run) is a regression testing platform for web applications,
which replaces manual and code-based testing with automated test runs and failure notifications.

The Reflect Agent is a networked deamon that establishes a secure tunnel
from an internal local area network back to Reflect.
This allows customers to use Reflect's cloud-based platform
to create and run tests against private, non-publicly-accessible applications.

The Reflect Agent runs as a docker container on a host within the private network.
It establishes a [Wireguard](https://www.wireguard.com/) tunnel to Reflect's API
through which the Reflect browsers can reach applications in the private network.

## Background

Reflect is a cloud-based platform where users can instantiate browser instances and
interact with their own web applications through those cloud browsers.
From these interactions, Reflect automatically generates repeatable test cases.
Then, users can run those test cases against their applications without manual intervention.
Reflect notifies users if the test cases were succesfully performed or not.

Since Reflect's browsers run on the public Internet, the web application under test must be publicly accessible.
However, some web applications are not publicly-accessible on the Internet.
In these cases, users run the Reflect Agent to establish a secure network connection
between their environment and the Reflect platform.
This allows private web applications to be accessible, but only to Reflect's cloud browsers.

## Installation

The simplest installation is to run the agent on a host
that has both a public and private IP address,
where the private IP address is on the same network subnet as the private web applications to be tested.
The agent will bind to a UDP port on the public IP address and listen for incoming Reflect browser sessions.
Typically, the host will have a restricted network ACL limited to allowing traffic only from Reflect.

NOTE: installing the agent behind a NAT requires establishing a port-forwarding rule
on the NAT for the UDP port that the agent binds to.

To install the agent, you'll need `docker` installed, and then run:

```
$ ./build-agent.sh
```

(In the future, Reflect may release an official container image publicly.)

## Running the Agent

To run the agent, you'll need your Reflect account API key,
which can be found on the __Settings__ page in the Reflect web UI.

Additionally, you can optionally specify the public UDP port that the agent
will bind to in order to listen for connections from Reflect cloud browsers.

Then, run:

```
$ ./run-agent.sh <reflect-api-key> [UDP port]
```

The agent will generate a new keypair when it launches and
register with Reflect using your account API key.
Then, it will listen for connections from Reflect browser sessions indefinitely.

NOTE: Reflect only supports a single agent per account.
As a result, you should not run multiple agents at once.
In all cases, the last agent to register is the only agent that Reflect recognizes.

## Stopping the Agent

To stop the agent, run:

```
$ ./stop-agent.sh
```

## Support

For questions about using the Reflect Agent with your Reflect account,
please email us at support@reflect.run and we'll be glad to assist.

