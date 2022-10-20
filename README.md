# Reflect Agent

[Reflect](https://reflect.run) is a regression testing platform for web applications,
which replaces manual and code-based testing with automated test runs and failure notifications.

The Reflect Agent is a networked deamon that establishes a secure tunnel
from an internal local area network back to Reflect.
This allows customers to use Reflect's cloud-based platform
to create and run tests against private, non-publicly-accessible applications.

The Reflect Agent runs as a docker container on a host within the private network.
It establishes a [Wireguard](https://www.wireguard.com/) tunnel via Reflect's API
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

The agent assumes a Linux host to run the container, and
requires Linux kernel version 5.6 or later
because it uses the host's Wireguard networking module.
Additionally, since the agent runs as a container on the host,
it requires Docker or Podman to be installed on the host.
Typically, the host will have a restricted network ACL as well.

The agent binds to a UDP port on the host's network interface and
polls the Reflect API to identify Reflect browser sessions that need the agent.
For each agent-based browser session in Reflect,
the agent initiates a secure connection over Wireguard.

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
If you're running the agent on a host behind a NAT,
you can specify the `-n` flag to improve the reliability of the connection.

Then, run the agent using the following command usage options:

```
$ ./run-agent.sh -k <reflect_api_key> [-p <public_port] [-n]
	Runs the Reflect Agent and connects to the specified Reflect account

	-k reflect_api_key
		The API key for the Reflect account

	-p public_port
		The public port on the host machine, default 10009

	-n
		Use a persistent connection to Reflect when behind a NAT, default false
```

The agent will generate a new keypair when it launches and
register with Reflect using your account API key.
Then, it will poll the Reflect API to learn of new agent-based browser sessions
and establish a connection to the browser sessions directly.

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

