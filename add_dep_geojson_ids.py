import json

# Adjust these file paths as necessary
input_file = '/home/franci/code/francilobbie/projets/rails_7_1/rubyist/public/departements-avec-outre-mer.geojson'
output_file = '/home/franci/code/francilobbie/projets/rails_7_1/rubyist/public/departments_with_ids.geojson'

# Open and load the GeoJSON data
with open(input_file, 'r', encoding='utf-8') as file:
    data = json.load(file)

# Assuming each department feature has a unique 'code' in its properties
# Adjust 'code' to match the property name from your GeoJSON file
for i, feature in enumerate(data['features']):
    feature['id'] = feature['properties']['code']  # Use the department's code as its ID

# Write the modified data back to a new GeoJSON file
with open(output_file, 'w', encoding='utf-8') as file:
    json.dump(data, file, indent=2)
