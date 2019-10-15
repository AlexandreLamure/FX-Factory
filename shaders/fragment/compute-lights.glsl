#version 430

struct Material // Use vec3 instead of sampler2D to avoid expensive copy of data
{
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
};

struct DirLight
{
    vec3 dir;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

struct PointLight
{
    vec3 pos;

    float constant;
    float linear;
    float quadratic;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

#define NB_DIR_LIGHTS 1
#define NB_POINT_LIGHTS 2

vec3 compute_dir_light(DirLight light, Material material, vec3 normal, vec3 camera_dir)
{
    vec3 light_dir = normalize(-light.dir);
    // diffuse shading
    float diff = max(dot(normal, light_dir), 0.0);
    // specular shading
    vec3 reflect_dir = reflect(-light_dir, normal);
    float spec = pow(max(dot(camera_dir, reflect_dir), 0.0), material.shininess); //FIXME: shininess
    // combine results
    vec3 ambient  = light.ambient  * material.ambient;
    vec3 diffuse  = light.diffuse  * diff * material.diffuse;
    vec3 specular = light.specular * spec * material.specular;
    return (ambient + diffuse + specular);
}

vec3 compute_point_light(PointLight light, Material material, vec3 normal, vec4 interpolated_pos, vec3 camera_dir)
{
    vec3 light_dir = normalize(light.pos - interpolated_pos.xyz);
    // diffuse shading
    float diff = max(dot(normal, light_dir), 0.0);
    // specular shading
    vec3 reflect_dir = reflect(-light_dir, normal);
    float spec = pow(max(dot(camera_dir, reflect_dir), 0.0), material.shininess);
    // attenuation
    float distance = length(light.pos - interpolated_pos.xyz);
    float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));
    // combine results
    vec3 ambient  = light.ambient  * material.ambient;
    vec3 diffuse  = light.diffuse  * diff * material.diffuse;
    vec3 specular = light.specular * spec * material.specular;
    ambient  *= attenuation;
    diffuse  *= attenuation;
    specular *= attenuation;
    return (ambient + diffuse + specular);
}

vec4 compute_lights(vec4 interpolated_pos, vec3 interpolated_normal,
                    vec3 camera_pos, vec4 color_org,
                    Material material,
                    DirLight dir_lights[NB_DIR_LIGHTS],
                    PointLight point_lights[NB_POINT_LIGHTS])
{
    vec3 camera_dir = normalize(camera_pos - interpolated_pos.xyz);

    // Directional lighting
    vec3 light_color = vec3(0);
    for(int i = 0; i < NB_DIR_LIGHTS; i++)
        light_color += compute_dir_light(dir_lights[i], material, interpolated_normal, camera_dir);
    // Point lights
    for(int i = 0; i < NB_POINT_LIGHTS; i++)
        light_color += compute_point_light(point_lights[i], material, interpolated_normal, interpolated_pos, camera_dir);
    // Spot light
    //light_color += CalcSpotLight(spotLight, norm, FragPos, camera_dir);

    //return vec4(light_color, 1);

    return vec4(color_org.rgb * light_color, color_org.a);
}