class IngestPipeline

  def initialize(name, metadata)
    @name = name
    @metadata = metadata
  end

  def pipeline
    Jbuilder.new do |json|
      generate_description(json)
      generate_pipeline(json)
    end.attributes!.with_indifferent_access
  end

  private

  def generate_description(json)
    json.description "Pipeline for #{@name}"
  end

  def generate_pipeline(json)
    json.processors do
      @metadata.entries.map do |field, meta|
        generate_all_processors_for_field(json, field, meta.with_indifferent_access)
      end
    end
  end

  def generate_all_processors_for_field(json, target_field, meta)
    source_field = meta[:source] || meta[:copy_from]
    if source_field
      if target_field != source_field
        rename(json, target_field, meta[:source]) if meta[:source]
        trim(json, target_field, meta[:copy_from]) if meta[:copy_from]
      end
    elsif meta[:constant]
      constant(json, target_field, meta[:constant])
    end
    meta[:transformations].each do |transformation_entry|
      json.child! do
        generate_processor_for_target_field(target_field, json, transformation_entry)
      end
    end if meta[:transformations].present?
  end

  def generate_processor_for_target_field(field, json, transformation_entry)
    if transformation_entry.instance_of?(String)
      DataSources::StringTransformation.generate_processor(json, field, transformation_entry)
    else
      process_hash(json, field, transformation_entry)
    end
  end

  def rename(json, target_field, field)
    json.child! do
      json.rename do
        json.field field
        json.target_field target_field
      end
    end
  end

  def trim(json, target_field, field)
    json.child! do
      json.trim do
        json.field field
        json.target_field target_field
      end
    end
  end

  def constant(json, target_field, field)
    json.child! do
      json.set do
        json.field target_field
        json.value field
      end
    end
  end

  def process_hash(json, field, transformation_entry_hash)
    transformation_klass_name = "DataSources::#{transformation_entry_hash.keys.first.to_s.camelize}Transformation"
    if class_exists?(transformation_klass_name)
      klass = transformation_klass_name.constantize
      klass.generate_processor(json, field, transformation_entry_hash.values.first)
    else
      array = transformation_entry_hash.to_a.flatten
      DataSources::StringTransformation.generate_processor(json, field, array.first, array.from(1))
    end
  end

  def class_exists?(class_name)
    Module.const_get(class_name).is_a?(Class)
  rescue NameError
    false
  end

end