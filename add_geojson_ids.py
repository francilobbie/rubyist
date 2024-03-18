import json

input_file = '/home/franci/code/francilobbie/projets/rails_7_1/rubyist/public/regions-avec-outre-mer.geojson'
output_file = '/home/franci/code/francilobbie/projets/rails_7_1/rubyist/public/regions-avec-outre-mer-whith-ids.geojson'

with open(input_file, 'r') as file:
    data = json.load(file)

for i, feature in enumerate(data['features']):
    feature['id'] = feature['properties']['code']  # Or any unique field

with open(output_file, 'w') as file:
    json.dump(data, file, indent=2)
