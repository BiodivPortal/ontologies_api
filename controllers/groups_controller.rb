class GroupsController < ApplicationController

  ##
  # Ontology groups
  get "/:acronym/groups" do
    ont = Ontology.find(params["acronym"], load_attrs: {group: Group.goo_attrs_to_load})
    error 404, "You must provide a valid `acronym` to retrieve an ontology" if ont.nil?
    reply ont.group
  end

  namespace "/groups" do
    # Display all groups
    get do
      groups = Group.all(load_attrs: Group.goo_attrs_to_load(includes_options))
      reply groups
    end

    # Display a single group
    get '/:acronym' do
      acronym = params["acronym"]
      g = Group.find(acronym)
      error 404, "Group #{acronym} not found" if g.nil?
      reply 200, g
    end

    # Create a group with the given acronym
    put '/:acronym' do
      acronym = params["acronym"]
      group = Group.find(acronym)

      if group.nil?
        group = instance_from_params(Group, params)
      else
        error 400, "Group exists, please use HTTP PATCH to update"
      end

      if group.valid?
        group.save
      else
        error 400, group.errors
      end
      reply 201, group
    end

    # Update an existing submission of an group
    patch '/:acronym' do
      acronym = params["acronym"]
      group = Group.find(acronym)

      if group.nil?
        error 400, "Group does not exist, please create using HTTP PUT before modifying"
      else
        group.load unless group.loaded?
        populate_from_params(group, params)

        if group.valid?
          group.save
        else
          error 400, group.errors
        end
      end
      halt 204
    end

    # Delete a group
    delete '/:acronym' do
      group = Group.find(params["acronym"])
      group.load unless group.loaded?
      group.delete
      halt 204
    end
  end
end