## Architecture

```dart
class QueryClient {
    fetchQuery(query) {

    }
}
```

QueryFn: () => Future<Any>
QueryKey: ["medicines", "id", {"page": 1}]
StaleTime: 3000 - > Stale

queryClient.invalidateQueries({
key: ["medicines"],
exact: false
})

queryClient.refetchQueries({
key: ["medicines"],
exact: false
})
