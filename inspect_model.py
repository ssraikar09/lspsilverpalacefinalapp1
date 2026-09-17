import tensorflow as tf

def main():
    interpreter = tf.lite.Interpreter(model_path=r"C:\lsp_silver_app\assets\models\mobilenet_v2_feature_vector.tflite")
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()[0]
    output_details = interpreter.get_output_details()[0]

    print("Input Tensor Shape:", input_details['shape'])
    print("Input Tensor Type:", input_details['dtype'])
    print("Output Tensor Shape:", output_details['shape'])
    print("Output Tensor Type:", output_details['dtype'])

if __name__ == "__main__":
    main()
