{
  'targets': [
    {
      'target_name': 'bindings',
      'sources': [
        'src/LocationManager.mm',
        'src/CLLocationBindings.mm'
      ],
      'link_settings': {
        'libraries': [
          'CoreLocation.framework'
        ]
      }
    }
  ]
}
