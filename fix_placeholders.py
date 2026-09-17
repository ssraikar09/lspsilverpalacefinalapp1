import re

file_path = 'lib/data/sample_data.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace category imagePath placeholders with empty string
content = re.sub(r'imagePath:\s*\'https://via\.placeholder\.com/[^\']+\'', \"imagePath: ''\", content)

# Replace product imageUrls placeholders with empty list
content = re.sub(r'imageUrls:\s*\[\'https://via\.placeholder\.com/[^\']+\'\]', \"imageUrls: []\", content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Replacement complete.')
