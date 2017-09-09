
lambda { |stdout,stderr,status|
  output = stdout + stderr
  syntax_error_pattern = /Exception in thread/
  ran_pattern = /Ran (\d+) tests containing (\d+) assertions.(\s*)(\d+) failures, (\d+) errors./
  return :amber if syntax_error_pattern.match(output)
  return :red   if output.scan(ran_pattern).any? { |res| res[3] != '0' || res[4] != '0' }
  return :green if output.scan(ran_pattern).any? { |res| res[3] == '0' && res[4] == '0' }
  return :amber
}
