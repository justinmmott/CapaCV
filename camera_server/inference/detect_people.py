# Credit: Largely based on the tensorflow object detection API tutorial
#         https://github.com/tensorflow/models/blob/master/research/object_detection/object_detection_tutorial.ipynb

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

############ Set up labels ###########
tf_dir = pathlib.Path('/opt/miniconda3/lib/python3.7/site-packages/tensorflow/')
# List of the strings that is used to add correct label for each box.
PATH_TO_LABELS = str(tf_dir/'models/research/object_detection/data/mscoco_label_map.pbtxt')
category_index = label_map_util.create_category_index_from_labelmap(PATH_TO_LABELS, use_display_name=True)

########## Session specific #############
# patch tf1 into `utils.ops`
utils_ops.tf = tf.compat.v1
# Patch the location of gfile
tf.gfile = tf.io.gfile
tf.enable_eager_execution()
# Make a session
sess = tf.compat.v1.Session()

########## Helpers ############

def load_model(model_dir):
    print("Model dir: ", model_dir)
    model = tf.saved_model.load_v2(str(model_dir))
    model = model.signatures['serving_default']
    return model

def analyze_single_image(model, image_path):
    num_people = 0
    image = np.array(Image.open(image_path))
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

def run_inference_for_single_image(model, image_path):
    image = np.array(Image.open(image_path))
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
  output_dict = run_inference_for_single_image(model, image_path)
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

########## Set up model #############
PERSON_CLASS = 1
model_name = 'ssd_mobilenet_v1_coco_2018_01_28'
detection_model = load_model(pathlib.Path.cwd().parent/'models'/model_name/'saved_model')

########## Executed code ######################

def count_people(image_path):
    return analyze_single_image(detection_model, image_path)

if __name__ == '__main__':
    PATH_TO_TEST_IMAGES_DIR = pathlib.Path(tf_dir/'models/research/object_detection/test_images')
    TEST_IMAGE_PATHS = sorted(list(PATH_TO_TEST_IMAGES_DIR.glob("*.jpg")))
    print("Test image paths: ", TEST_IMAGE_PATHS)
    for image_path in TEST_IMAGE_PATHS:
        print("Num people: ", count_people(image_path))
        # show_inference(detection_model, image_path)
