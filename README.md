# Claxy: simple proxy middleware for clack

Claxy is - at this point - a simple and unambitious proxy for clack web applications.

## Usage

    (lack:builder 
      ...
      (claxy:middleware '(("/resources/" "https://somewhe.re/else/resources/")
                          ("/places/" "https://somewhe.re/else/locations/")
                          ("/app/" "http://localhost:8080/")))
       ...
       )
       
Claxy accepts, as its parameter, a list of substitutions. Each substitution is a list containing an
incoming URL path segment to match, and a replacement. The path segment must be at the root of the
path.

## Author

Ben McGunigle (bnmcgn at gmail.com)

## Copyright

Copyright (c) 2021 Ben McGunigle

## License

Apache License version 2.0
