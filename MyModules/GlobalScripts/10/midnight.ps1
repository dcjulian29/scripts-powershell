function midnight()
{
  (get-date).AddSeconds("-" + ((get-date).TimeOfDay.TotalSeconds - 1))
}
