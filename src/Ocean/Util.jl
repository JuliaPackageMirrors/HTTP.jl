
module Util
  import HTTP
  
  # Utility to allow match(re, str)[1]
  function ref(m::RegexMatch, i::Int64)
    return m.captures[i]
  end
  
  function get_single(dict::Dict{String,Any}, param::String)
    if haskey(dict, param)
      val = dict[param]
      if isa(val, Array)
        return val[1]
      else
        return val
      end
    else
      return false
    end
  end
  gs = get_single
  
  # TODO: Maybe this can be refactored into a prettier macro?
  #       (Too late at night to figure out macroing this right now.)
  # Example:
  #   function scope_me(scope::ScopeThingy, b, c)
  #     return scope.a+b+c
  #   end
  #   scoped = enscopen(scope_thingy, scope_me)
  #   party = scoped(b, c)
  function enscopen(scope::Any, func::Function)
    return function(args...)
      return func(scope, args...)
    end
  end
  
  function redirect(res::HTTP.Response, path::String, status::Integer)
    res.headers["Location"] = "/"
    res.status = status
    return "Redirecting to $path..."
  end
  redirect(res::HTTP.Response, path::String) = redirect(res, path, 302)
  
  function memo(cache::Associative, key::Union(String,Symbol),compute::Function)
    key = symbol(key)
    if has(cache, key)
      # pass
    else
      val = compute()
      cache[key] = val
    end
    return cache[key]
  end
  # Allow for memo(cache, key) do ... end
  memo(compute::Function, cache::Associative, key::Union(String,Symbol)) =
    memo(cache, key, compute)
  
  export ref, gs, get_single, redirect, memo
end
