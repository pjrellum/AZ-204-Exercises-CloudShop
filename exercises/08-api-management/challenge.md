# Challenge: API Policies & Response Transformation

## Scenario

CloudShop's Orders API is being exposed to partners. You need to:
1. **Add mock responses** for API documentation/testing without hitting the backend
2. **Clean up responses** by adding custom headers and removing internal ones

## Learning Objectives

- Apply APIM policies (exam topic)
- Use mock responses for testing
- Transform API responses with policies
- Understand inbound vs outbound policy sections

## Prerequisites

Complete the main exercise first - you need a working APIM instance with the Orders API.

## Part 1: Add a Mock Response

Create a mock endpoint that returns sample data without calling the backend. This is useful for API documentation and testing.

### Step 1: Open Policy Editor

Use the Azure Portal: APIM > APIs > Orders API > **GET /orders** operation > Inbound processing > Code editor

This applies the policy only to the GET orders operation, not to health check or other endpoints.

### Step 2: Add Mock Response Policy

Add this policy to return a mock response when `?mock` is in the query string:

```xml
<policies>
    <inbound>
        <base />
        <choose>
            <when condition='@(context.Request.Url.QueryString.Contains("mock"))'>
                <return-response>
                    <set-status code="200" reason="OK" />
                    <set-header name="Content-Type" exists-action="override">
                        <value>application/json</value>
                    </set-header>
                    <set-body>@(new JObject(
                        new JProperty("message", "Mock response - Orders API"),
                        new JProperty("orders", new JArray(
                            new JObject(new JProperty("id", "MOCK-001"), new JProperty("customer", "Test Customer"), new JProperty("total", 99.99)),
                            new JObject(new JProperty("id", "MOCK-002"), new JProperty("customer", "Demo Partner"), new JProperty("total", 149.99))
                        ))
                    ).ToString())</set-body>
                </return-response>
            </when>
        </choose>
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
```

### Step 3: Test Mock Response

```bash
# Get your subscription key
SUBSCRIPTION_KEY=$(az rest \
    --method POST \
    --uri "https://management.azure.com/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_NAME/subscriptions/master/listSecrets?api-version=2022-08-01" \
    --query primaryKey -o tsv)

# Test mock response (should return mock data, not hit backend)
curl -s -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
    "https://$APIM_NAME.azure-api.net/orders/orders?mock" | jq

# Test real response (should hit backend)
curl -s -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
    "https://$APIM_NAME.azure-api.net/orders/orders" | jq
```

**Expected:** With `?mock` in the query string, returns mock data instantly. Without it, calls the real backend.

## Part 2: Transform Response

The Orders API returns internal fields that partners shouldn't see. Remove them before responding.

### Step 1: Check Current Response

```bash
curl -s -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
    "https://$APIM_NAME.azure-api.net/orders/orders" | jq
```

Notice fields like `source` or internal IDs that partners don't need.

### Step 2: Add Response Transformation

Add this to the `<outbound>` section to add a custom header and set content type:

```xml
<outbound>
    <base />
    <set-header name="X-CloudShop-Version" exists-action="override">
        <value>1.0</value>
    </set-header>
    <set-header name="X-Powered-By" exists-action="delete" />
</outbound>
```

### Step 3: Test Transformation

```bash
# Check response headers (-i shows headers with response body)
curl -s -i -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
    "https://$APIM_NAME.azure-api.net/orders/orders"
```

**Expected:** Response includes `X-CloudShop-Version: 1.0` header, no `X-Powered-By` header.

## Part 3: Add IP Filtering (Bonus)

Restrict API access to specific IP addresses:

```xml
<inbound>
    <base />
    <!-- Allow only specific IPs (replace with your IP) -->
    <ip-filter action="allow">
        <address>YOUR.IP.ADDRESS.HERE</address>
    </ip-filter>
    <!-- Or block specific IPs -->
    <!-- <ip-filter action="forbid">
        <address>BLOCKED.IP.HERE</address>
    </ip-filter> -->
</inbound>
```

To find your IP: `curl ifconfig.me`

Test by adding your IP to the allow list, then try from a different network (should get 403 Forbidden).

## Validation Checklist

- [ ] Mock response returns sample data with `?mock=true`
- [ ] Real endpoint still works without `?mock=true`
- [ ] Custom header `X-CloudShop-Version` appears in responses
- [ ] `X-Powered-By` header is removed
- [ ] (Bonus) IP filtering blocks unauthorized IPs

## Key Policy Concepts

| Policy | Section | Purpose |
|--------|---------|---------|
| `choose/when` | any | Conditional logic |
| `return-response` | inbound | Return immediately without calling backend |
| `set-header` | inbound/outbound | Add, modify, or delete headers |
| `set-body` | inbound/outbound | Transform request/response body |
| `ip-filter` | inbound | Allow/deny by IP address |
| `rewrite-uri` | inbound | Change backend URL path |

## Common Exam Topics

- Policy sections: inbound → backend → outbound → on-error
- The `<base />` element inherits policies from parent scopes
- `choose/when/otherwise` for conditional processing
- `return-response` to short-circuit and return without backend call

## Note on Rate Limiting

The `rate-limit` policy is **not supported in the Consumption tier** (it requires in-memory counters).
For rate limiting in Consumption tier, use `rate-limit-by-key` with Azure Cache for Redis.
