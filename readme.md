## Anagram solver as a service

### Solver

Finding anagrams for all combinations of letters in a word is a quite hard
problem. Naive solutions do not scale, because generating the subsequences has
an exponential runtime of O(2^n).

However, there is a much better approach, by using a 
[directed acyclic word graph (DAWG)](https://en.wikipedia.org/wiki/Deterministic_acyclic_finite_state_automaton).
and recursive backtracking. This is partly inspired by
[Appel and Jacobsen's paper on the World's Fastest Scrabble Program](https://dl.acm.org/citation.cfm?id=42420)
(free [PDF](http://www.cs.columbia.edu/~kathy/cs4701/documents/aj.pdf)).

It is possible to implement the algorithm with a [trie](https://en.wikipedia.org/wiki/Trie).
However, a DAWG is more space efficient, because it reuses the character nodes.
Words are then mapped by using multiple edges. This is also the reason why the
DAWG is called a finite state automaton.

The algorithm descends recursively on the word graph, building partial words
from the nodes it comes across. If a valid word is, it will be added to the
result. The valid word check can be implemented by looking up the word in the
word graph, or, even faster, but at the expense of memory, using an additional
set of all valid words. When the algorithm comes across end-of-word, which means
that there are no outgoing edges anymore, it will back out until the next valid
node and descend from there on.

The implementation can be found at the
[anagram-solver](https://github.com/jotrk/anagram-solver) repository at Github.

### Service

The service is currently implemented as a primitive rest api.
Example query: `http://example.com:1525/complete/master%20of%20the%20universe`

The implementation can be found at the
[anagram-service](https://github.com/jotrk/anagram-service) repository at Github.

## Completion as a service

### Engine

Providing completion for text input is a typical use case for tries. The
implementation is extremely simple. For a given partial word, descend on the
tree and return all words in the subtree found at the last node of the partial
word. Since DAWGs are more space efficient, but otherwise similar to tries, this
implementation is based on a DAWG again.

The implementation can be found at the
[completion-engine](https://github.com/jotrk/completion-engine) repository at Github.

### Service

The service is currently implemented as a primitive rest api.
Example query: `http://example.com:1880/complete/master%20of%20the%20univ`

The implementation can be found at the
[completion-service](https://github.com/jotrk/completion-service) repository at Github.

## Web user interface

The user interface is currently a very simplistic piece of HTML and Javascript,
which uses the [autocomplete](http://jqueryui.com/autocomplete/) feature of the
jQuery user interface library. The
[index.html](https://github.com/jotrk/webui-service/blob/master/index.html) file
can be accessed over an http server, directly from disk (`file:///...`) or by
running the small http server in the package.

The implementation can be found at the
[webui-service](https://github.com/jotrk/webui-service) repository at Github.

## Dockerfile

This repository contains a Dockerfile for building the whole package as a Docker
container. This is not meant as a proper web service, but only for trying it
out.

### Building and Pulling

There are two options: Either build the Docker container yourself with `docker
build -t anagram-web-service .`, which might take some time, or just pull the
container: `docker pull jotrk/anagram-web-service`.

### Running

Run the docker container like below, to expose all necessary ports.

```
docker run -p 1525:1525 -p 1880:1880 -p 8888:8888 jotrk/anagram-web-service
```

The service can now be accessed through [http://localhost:8888/](http://localhost:8888/).

The anagram service is available at port `1525`, and the completer at `1880`.
