import os
import re
import sys
import zipfile

def get_root_mapping(file_paths):
  init_locations = [path[:-12] for path in file_paths
                    if path.endswith('/__init__.py')]
  # TODO (dung) do something with this hack
  init_locations += ['proto']
  sorted_paths = sorted(init_locations)
  current_root = sorted_paths[0]
  root_mapping = {current_root: current_root.split('/')[-1]}
  for i in range(1, len(sorted_paths)):
    if not sorted_paths[i].startswith(current_root):
      current_root = sorted_paths[i]
      root_mapping[current_root] = current_root.split('/')[-1]
    else:
      len_diff = len(current_root) - len(root_mapping[current_root])
      root_mapping[sorted_paths[i]] = sorted_paths[i][len_diff:]

  return root_mapping

def convert_to_root(path, root_mapping):
  file_path = path.split('/')
  folder = '/'.join(file_path[:-1])
  if folder not in root_mapping:
    raise Exception(
      'Failed to find the parent directory with __init__.py for file %s' %
      path)
  return '%s/%s' % (root_mapping[folder], file_path[-1])

if __name__ == "__main__":
  assert len(sys.argv) >= 1
  output = sys.argv[1]

  root_mapping = get_root_mapping(sys.argv[2:])
  with zipfile.ZipFile(output, 'w') as zf:
    # TODO (dung) do something with this hack
    zf.writestr('sparkel_proto/__init__.py', '')
    for path in sys.argv[2:]:
      match = re.match(r'bazel-out/[^/]+/genfiles/', path)
      if match:
        new_path = path[len(match.group()):]
      else:
        new_path = path
      zip_path = convert_to_root(new_path, root_mapping)
      zf.write(path, zip_path)
