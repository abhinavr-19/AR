from diffusers import StableDiffusionPipeline
import torch
import gradio as gr

print("Loading the Stable Diffusion model (this may take a minute)...")
pipeline = StableDiffusionPipeline.from_pretrained("runwayml/stable-diffusion-v1-5", torch_dtype=torch.float16)
pipeline.to("cuda")
print("Model loaded successfully!")

def generate_image(prompt, guidance_scale):
    """
    Generate an image from a text prompt using Stable Diffusion.

    Args:
        prompt (str): The text prompt for generating the image.
        guidance_scale (float): Controls how closely the image matches the prompt.

    Returns:
        PIL.Image.Image: The generated image.
    """
    if not prompt.strip():
        return "Error: Prompt cannot be empty!"
    try:
        image = pipeline(prompt, guidance_scale=guidance_scale).images[0]
        return image
    except Exception as e:
        return f"Error: {str(e)}"

with gr.Blocks() as demo:
    gr.Markdown("# 🖼 Text-to-Image Generator by Abhinav ")
    gr.Markdown("Enter a text description below to generate an image.")

    with gr.Row():
        prompt_input = gr.Textbox(label="Enter Image Prompt", placeholder="e.g., A beautiful place in Kerala", lines=2)
        guidance_slider = gr.Slider(label="Guidance Scale", minimum=5.0, maximum=15.0, value=7.5, step=0.5)

    generate_button = gr.Button("Generate Image")
    output_image = gr.Image(label="Generated Image")

    generate_button.click(
        fn=generate_image,
        inputs=[prompt_input, guidance_slider],
        outputs=output_image
    )
demo.launch()
