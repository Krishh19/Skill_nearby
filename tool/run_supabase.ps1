param(
  [Parameter(Mandatory = $true)]
  [string]$PublishableKey,
  [string]$Device = ''
)

$projectUrl = 'https://vdnkjwckhbvbgyrqgkuq.supabase.co'
$args = @(
  'run',
  "--dart-define=SUPABASE_URL=$projectUrl",
  "--dart-define=SUPABASE_PUBLISHABLE_KEY=$PublishableKey"
)
if ($Device -ne '') { $args += @('-d', $Device) }

flutter @args
