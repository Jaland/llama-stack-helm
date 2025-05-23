Running the Stack Locally

To run this stack locally: [link](local.md)

## OpenShift Installation
Helm chart to install Llama-stack and an MCP server on OpenShift

This helm chart deploys the following components:

* A postgresql database containing customer orders
* An MCP Server written in node.js providing functions to read and update the customer orders database
* A Llama-stack server using the docker.io/llamastack/distribution-remote-vllm image
* A chat-ui written in python and streamlit using the llama-stack-client python sdk

Once these components are deployed in OpenShift you should see:

![openshift](./assets/openshift.png)

## Pre-requsuites

* OpenShift cluster 
* Helm CLI
* OpenShift CLI
* Access to a running LLM.  Tested with llama32-3b
* llama-stack-client CLI (optional)

## Installation

Login to your OpenShift cluster with the OpenShift CLI

Create a new project e.g. `llama-stack`

```
oc new-project llama-stack
```

Set environment variables for LLM connection

```
export LLM_URL=???
export LLM_TOKEN=???
export LLM_MODEL=llama32-3b
```

Run the helm chart with the helm CLI

```
helm install llama-stack ./llama-stack --set "vllm.url=$LLM_URL/v1,vllm.apiKey=$LLM_$TOKEN,vllm.inferenceModel=$LLM_MODEL"
```

## Llama-stack configuration

Watch the status of the pods with

```
oc get pods -w
```

Once the Llama-stack pod is running successfully, you will need to register the MCP server.  To do this, first find the route of your llama-stack server

```
export LLAMA_STACK_URL=$(oc get route llama-stack -o jsonpath='{.spec.host}')
```

```
 curl -X POST -H "Content-Type: application/json" \
--data \
'{ "provider_id" : "model-context-protocol", "toolgroup_id" : "mcp::orders-service", "mcp_endpoint" : { "uri" : "http://llama-stack-mcp:8000/sse"}}' \
 https://$LLAMA_STACK_URL/v1/toolgroups 
 ```

Check the status of the toolgroup:

`llama-stack-client configure --endpoint  https://$LLAMA_STACK_URL --api-key none`

`llama-stack-client toolgroups get mcp::orders-service`

You should see:

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━┳━━━━━━┓
┃ description               ┃ identifier  ┃ metadata                  ┃ parameters                 ┃ provider_id            ┃ provider_resource_id ┃ tool_host              ┃ toolgroup_id        ┃ type ┃
┡━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━╇━━━━━━┩
│ Find a customers orders   │ findorder   │ {'endpoint':              │ [Parameter(description='T… │ model-context-protocol │ findorder            │ model_context_protocol │ mcp::orders-service │ tool │
│ details                   │             │ 'http://llama-stack-mcp:… │ id of the order',          │                        │                      │                        │                     │      │
│                           │             │                           │ name='orderid',            │                        │                      │                        │                     │      │
│                           │             │                           │ parameter_type='string',   │                        │                      │                        │                     │      │
│                           │             │                           │ required=True,             │                        │                      │                        │                     │      │
│                           │             │                           │ default=None)]             │                        │                      │                        │                     │      │
│ Update an order status    │ updateorder │ {'endpoint':              │ [Parameter(description='T… │ model-context-protocol │ updateorder          │ model_context_protocol │ mcp::orders-service │ tool │
│                           │             │ 'http://llama-stack-mcp:… │ id of the order',          │                        │                      │                        │                     │      │
│                           │             │                           │ name='orderid',            │                        │                      │                        │                     │      │
│                           │             │                           │ parameter_type='string',   │                        │                      │                        │                     │      │
│                           │             │                           │ required=True,             │                        │                      │                        │                     │      │
│                           │             │                           │ default=None),             │                        │                      │                        │                     │      │
│                           │             │                           │ Parameter(description='The │                        │                      │                        │                     │      │
│                           │             │                           │ status of the order',      │                        │                      │                        │                     │      │
│                           │             │                           │ name='status',             │                        │                      │                        │                     │      │
│                           │             │                           │ parameter_type='string',   │                        │                      │                        │                     │      │
│                           │             │                           │ required=True,             │                        │                      │                        │                     │      │
│                           │             │                           │ default=None)]             │                        │                      │                        │                     │      │
└───────────────────────────┴─────────────┴───────────────────────────┴────────────────────────────┴────────────────────────┴──────────────────────┴────────────────────────┴─────────────────────┴──────┘
```

## Test the chat-app

Open the chat-ui in your browser (find the route with `oc get route llama-stack-chatui`)

From the chat-ui, you should be able to interact with the order-service via Llama-stack and MCP

![chat-ui](./assets/chat-ui.png)


## Clean up

To uninstall the helm chart, run:

```
helm uninstall llama-stack
```

