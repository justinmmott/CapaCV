import os
import pathlib

import numpy as np
import os
import six.moves.urllib as urllib
import sys
import tarfile
import tensorflow as tf
import zipfile

from collections import defaultdict
from io import StringIO
from matplotlib import pyplot as plt
from PIL import Image

from object_detection.utils import ops as utils_ops
from object_detection.utils import label_map_util
from object_detection.utils import visualization_utils as vis_util

PERSON_CLASS = 1

# patch tf1 into `utils.ops`
utils_ops.tf = tf.compat.v1

# Patch the location of gfile
tf.gfile = tf.io.gfile
tf.enable_eager_execution()

# Make a session
sess = tf.compat.v1.Session()

def load_model(model_dir):
    print("Model dir: ", model_dir)
    model = tf.saved_model.load_v2(str(model_dir))
    model = model.signatures['serving_default']
    return model

tf_dir = pathlib.Path('/opt/miniconda3/lib/python3.7/site-packages/tensorflow/')
# List of the strings that is used to add correct label for each box.
PATH_TO_LABELS = str(tf_dir/'models/research/object_detection/data/mscoco_label_map.pbtxt')
print("Path to labels: ", PATH_TO_LABELS)
category_index = label_map_util.create_category_index_from_labelmap(PATH_TO_LABELS, use_display_name=True)

def analyze_single_image(model, image):
    num_people = 0
    with sess.as_default():
        image = np.asarray(image)
        input_tensor = tf.convert_to_tensor(image)
        input_tensor = input_tensor[tf.newaxis,...]
        output_dict = model(input_tensor)
        num_detections = int(output_dict.pop('num_detections'))
        output_dict = {key:value[0, :num_detections].numpy() 
                       for key,value in output_dict.items()}
        output_dict['num_detections'] = num_detections
        output_dict['detection_classes'] = output_dict['detection_classes'].astype(np.int64)
        for label in output_dict['detection_classes']:
            if label == PERSON_CLASS:
                num_people += 1
    return num_people

def run_inference_for_single_image(model, image):
    with sess.as_default():
        image = np.asarray(image)
        # The input needs to be a tensor, convert it using `tf.convert_to_tensor`.
        input_tensor = tf.convert_to_tensor(image)
        # The model expects a batch of images, so add an axis with `tf.newaxis`.
        input_tensor = input_tensor[tf.newaxis,...]
        
        # Run inference
        output_dict = model(input_tensor)
        
        # All outputs are batches tensors.
        # Convert to numpy arrays, and take index [0] to remove the batch dimension.
        # We're only interested in the first num_detections.
        # print("Type of output_dict: ", type(output_dict))
        assert 'num_detections' in output_dict
        #print("Tyoe of value: ", type(output_dict['num_detections']))
        #print(output_dict['num_detections'])
        #print("Shape: ", tf.shape(output_dict['num_detections']))
        #print("Value", output_dict['num_detections'][0])
        num_detections = int(output_dict.pop('num_detections'))
        output_dict = {key:value[0, :num_detections].numpy() 
                       for key,value in output_dict.items()}
        output_dict['num_detections'] = num_detections
        
        # detection_classes should be ints.
        output_dict['detection_classes'] = output_dict['detection_classes'].astype(np.int64)       
        # Handle models with masks:
        if 'detection_masks' in output_dict:
            # Reframe the the bbox mask to the image size.
            detection_masks_reframed = utils_ops.reframe_box_masks_to_image_masks(
                output_dict['detection_masks'], output_dict['detection_boxes'],
                image.shape[0], image.shape[1])      
            detection_masks_reframed = tf.cast(detection_masks_reframed > 0.5,
                                               tf.uint8)
            output_dict['detection_masks_reframed'] = detection_masks_reframed.numpy()
    return output_dict
        
def show_inference(model, image_path):
  # the array based representation of the image will be used later in order to prepare the
  # result image with boxes and labels on it.
  image_np = np.array(Image.open(image_path))
  image_name = pathlib.Path(image_path).name
  Image.fromarray(image_np).save("in_" + image_name)
  # Actual detection.
  output_dict = run_inference_for_single_image(model, image_np)
  # Visualization of the results of a detection.
  vis_util.visualize_boxes_and_labels_on_image_array(
      image_np,
      output_dict['detection_boxes'],
      output_dict['detection_classes'],
      output_dict['detection_scores'],
      category_index,
      instance_masks=output_dict.get('detection_masks_reframed', None),
      use_normalized_coordinates=True,
      line_thickness=8)
  Image.fromarray(image_np).save("out_" + image_name)

if __name__ == '__main__':
    # If you want to test the code with your images, just add path to the images to the TEST_IMAGE_PATHS.
    PATH_TO_TEST_IMAGES_DIR = pathlib.Path(tf_dir/'models/research/object_detection/test_images')
    TEST_IMAGE_PATHS = sorted(list(PATH_TO_TEST_IMAGES_DIR.glob("*.jpg")))
    print("Test image paths: ", TEST_IMAGE_PATHS)

    model_name = 'ssd_mobilenet_v1_coco_2018_01_28'
    detection_model = load_model(pathlib.Path.cwd().parent/'models'/model_name/'saved_model')

    print(detection_model.inputs)
    print(detection_model.output_dtypes)
    print(detection_model.output_shapes)

    for image_path in TEST_IMAGE_PATHS:
        res = analyze_single_image(detection_model, np.array(Image.open(image_path)))
        print("Num people: ", res)
        # show_inference(detection_model, image_path)
