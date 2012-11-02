function First-Path
{
  $result = $null
  
  foreach ($arg in $args) {
    if ($arg -is [ScriptBlock])
    {
      $result = & $arg
    }
    else
    {
      $result = $arg
    }
 
    if ($result)
    {
      if (test-path "$result")
      {
        break
      }
    }
  }
  
  $result
}
