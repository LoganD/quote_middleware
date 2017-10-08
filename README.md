![CircleCI](https://circleci.com/gh/LoganD/quote_middleware.svg?style=svg&circle-token=ccd2d1005411375f7e13653caac96e8ae4ae4ba0)

This is a practice application built with reference to: https://github.com/chadwpry/practice/tree/master/rack-middleware

Practice: Rack Middleware
=========================

A practice designed to learn more about Rack middleware and
[Ricky Gervais Quotes](http://www.rickygervaisquotes.com/).


### Goal

Rack is a minimal and modular interface for developing web applications.
Rack middleware is a extension that sits between an HTTP request and an
application, thus the middleware term. You goal is to create a Rack
middleware that serves random quotes. The middleware, when complete, can
be inserted into an existing application to provide a fun set of quotes.
A sample fixture has been added for quotes by
[Ricky Gervais](http://www.rickygervaisquotes.com/).


### Expectations

* Use Bundler for gem dependencies
* Adhere to the standards of Rack and middleware
* Code is tested with RSpec
* Quotes come from examples in fixtures directory
* Share project on github and commit regularly - do not commit all changes at once
* Prepare to discuss decisions/trade-offs
* Spend no more than 2 days on the challenge


### Request/Response

    Request: /quote

    Response Body: -example quote-

    Format: text/plain


### Testing

As mentioned, write all tests with the Rspec framework. A testing harness
should execute using the following command.

    $ rspec spec

_Do not test with an HTTP web interface, only test the library methods
and how they would respond if embedded in a web application._


### Testing Scenarios


GET "/quote"

- random quote is returned in body
- format is text/plain

POST "/quote"

- error response
- status of 404
- empty body

Alternative Requests

- pass through to next middleware component or application



### Links / Dependencies

These links are provided as a helper to find information. These are not the
only sources, so look for more if they do not give a full explanation.

[Bundler](http://bundler.io/)

[Rack](http://rack.github.io/)

[RSpec](http://rspec.info/)


### Extra credit ideas

* Setup continuous integration with Circle CI, Magnum CI, or Travis CI
* Integrate quotes via an online API

===========

## Bonus Additions:
The goal here was to extend the functionality to be able to return a random non-repeating quote, or all quotes in a randomized order.

### Solution:
##### Step 1
My initial approach was simple but inefficient:
```
create array with range 0... quote array length exclusive
generate random number 0... array.length
return quote at index array[random_index]
set array[random_index] = nil
compact array so array.length represents the number of actual values left
```
##### Step 2
To do better I replaced the compacting of the array O(n) with additional random numbers until an actual value was found. This had a smell because as you return more quotes the number of array value access misses increases. Generating random numbers are O(1) but generating increasing numbers of them can lead to [problems](https://crypto.stackexchange.com/questions/30380/how-does-generating-random-numbers-remove-entropy-from-your-system).

##### Suggested Solution
A set was suggested to me as a solution to this like so:
```
| Key    | Value |
| ------ | -     |
| 0      | 0     |
| 1      | 1     |
| 2      | 2     |
```
This is essentially my second approach but with a different data structure and still suffers from the misses on lookups.

The improvement was suggested as this:

```
| Key    | Value                              |
| ------ | ---------------------------------- |
| 0      | first element of randomized range  |
| 1      | second element of randomized range |
| 2      | third element of randomized range  |
```
The problem is that a set contains no inherent order so you'd have to maintain an index number count for lookups so that you can access a consecutively ordered key that maps to pre-randomized values to maintain 0(1) lookups without missing on lookup, which is also possible with my previous array implementation, thus you don't actually gain anything by using a set.

##### Step 3
My solution was to switch to a queue because it has continual 0(1) access to the next element without maintaining an outside index because it has an inherent order. A stack would also work since our solution is indifferent to LIFO vs FIFO.

#### Final Solution
By offloading the expensive computation (the creation of a randomized list of indexes) to a singular call when there is no list to reference, it makes the quote return 0(1) by using a Queue to pop off the top value.

Every time all quotes have been returned or at first call - O(n)
```
Create range from 0 to quote array length exclusive
randomize values into Queue
```
Each quote request - O(1)
```
pop a value off of the queue and return the quote of the corresponding index from the quote array
```

If the all-quotes return needs to be uniquely random on each call, then it has to create a new random order each time and is thus O(n). Otherwise, it could create one randomized order to start and keep returning that.

##### Further Improvements
1) For efficiency, a background job could be added to regenerate the `@quote_index` once it reaches 10% of it's original size. The shuffle on `\all-quotes` could also be offloaded to a background task to prevent it from having to be done on the request.

2) Having the shuffle on all quotes happen after returning the value to the user means it wouldn't happen on the users time and each request would have a pre-shuffled list.
