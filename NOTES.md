There are two directories here, `nokogiri` and `homebaked` that differ in their XML builders... and on other axes.

# Shared features

- API errors transformed into exceptions.
- Sessioning handled with a block.
- For demo, credentials from a git-ignored config.yaml.
- `verbose` flag for debugging and easy demos.

# Differences

`nokogiri`:
```
  fragment = Nokogiri::XML::DocumentFragment.parse("")
  Nokogiri::XML::Builder.with(fragment) do |xml|
    xml.id id
    xml.meta {
      xml.send("mf-note") {
        xml.note "Hello"
      }
    }
  end
  args_xml = fragment.to_xml
  mf.call("asset.set", args_xml)
```

`homebaked`:
```
  mf.set_asset id: id, meta: {mf_note: {note: "Hello"}}
```

## XML builder
I would prefer to use something off the shelf, but I think there are ways in which Nokogiri might be difficult to work with here:
- We need to generate an XML fragment rather than a document.
- We need to jump through hoops to handle dashes in element names. (Comment in the code suggests a way we might subclass the builder to help with dashes.)
- The proc-with-argument syntax is somewhat verbose; The proc-without-argument syntax makes it hard to use outside data.
- Composition of nested structures is a bit of a challenge.

With all that said, if we can pull together utilities so that the nokogiri demo is as readable as the homebaked, great!

## Service dispatch: `method_missing` vs. service argument
I think utilizing `method_missing` so we can call services as if they were methods improves readability. Possible variations:
- Grab the full list of services, store it in source, and check that services are in the list before dispatch.
- Build up our own list of services used incrementally: It might be useful to have a ready list of all the services we depend on.

## Service name: original order or verb-object
MediaFlux services are named in object-verb order:
This ensures that in a sorted list, services dealing with the same kind of object are sorted together.
But most of the time, we name methods in verb-object order. There are some advantages to this:
- Readability
- Service names can be long: When working with the same kind of object over several steps, it helps foreground what we're doing: `create_*` vs `set_*` vs `destroy_*`

The argument agaist this is the context shift needed when moving between MediaFlux documentation and our code.

