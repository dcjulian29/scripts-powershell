function Count-Object
{
  begin
  {
    $count = 0
  }
  process
  {
    $count += 1
  }
  end
  {
    $count
  }
}