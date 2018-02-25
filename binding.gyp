{
  'targets': [
    {
      'target_name': 'bindings',
      'sources': [
        'src/macos_clocation_wrapper.mm'
      ],
      'link_settings': {
        'libraries': [
          'CoreLocation.framework'
        ]
      }
    }
  ]
}
