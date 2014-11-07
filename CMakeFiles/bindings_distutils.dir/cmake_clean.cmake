FILE(REMOVE_RECURSE
  "CMakeFiles/bindings_distutils"
  "python-timestamp"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/bindings_distutils.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
