# Task 6: Test the API

## Objective

Verify that your API Management gateway is working correctly.

## Test Cases

### Test 1: Request Without Key (Should Fail)

```bash
curl -i https://$APIM_NAME.azure-api.net/orders
```

**Expected:** `401 Unauthorized`

### Test 2: Request With Key (Should Succeed)

```bash
curl -i -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
  https://$APIM_NAME.azure-api.net/orders
```

**Expected:** `200 OK` with JSON response

### Test 3: POST Request

```bash
curl -i -X POST \
  -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{"customer": "Alice", "product": "Widget", "quantity": 5}' \
  https://$APIM_NAME.azure-api.net/orders
```

**Expected:** `200 OK` or `201 Created` with order confirmation

## Validation Checklist

- [ ] Requests without subscription key return 401
- [ ] Requests with valid key succeed
- [ ] GET /orders returns data
- [ ] POST /orders accepts JSON body
- [ ] If rate limiting enabled: 11th request returns 429

---

## Using the Test Script

```bash
# Run all tests
./test/test-api.sh

# Or use the provided test data
./test/test-api.sh --verbose
```

---

## [Challenge] Test Rate Limiting

If you implemented rate limiting, test it:

```bash
# Send 11 requests quickly
for i in {1..11}; do
  echo "Request $i:"
  curl -s -o /dev/null -w "%{http_code}\n" \
    -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
    https://$APIM_NAME.azure-api.net/orders
done
```

**Expected:** First 10 return `200`, 11th returns `429 Too Many Requests`

---

## [Challenge] Custom Error Response

Make the 401 error return a friendly JSON message instead of the default.

<details>
<summary>Hint: on-error policy</summary>

Use the `<on-error>` section of your policy to customize error responses:

```xml
<on-error>
  <return-response>
    <set-status code="401" reason="Unauthorized" />
    <set-header name="Content-Type" exists-action="override">
      <value>application/json</value>
    </set-header>
    <set-body>{"error": "Missing or invalid subscription key"}</set-body>
  </return-response>
</on-error>
```

</details>

---

## Complete!

**Congratulations!** You've built the API gateway for CloudShop.

### What You Accomplished

- Created a storage account
- Deployed an Azure Function as the Orders API
- Set up API Management as a gateway
- Configured subscription key authentication
- (Optional) Added rate limiting
- Tested the complete flow

### Run Final Validation

```bash
./validate/check-all.sh
```

### Next Steps

Continue to **[Exercise 09a: Event Grid](../../09a-event-grid/)** where you'll configure automatic order processing when files are uploaded to blob storage.

---

**Previous:** [05-configure-api.md](05-configure-api.md)
