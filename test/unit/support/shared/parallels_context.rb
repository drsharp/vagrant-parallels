shared_context "parallels" do
  let(:parallels_context) { true                                }
  let(:uuid)              { "9876-dcba-8765-hgfe"               }
  let(:parallels_version) { "9"                                 }
  let(:subprocess)        { double("Vagrant::Util::Subprocess") }

  # this is a helper that returns a duck type suitable from a system command
  # execution; allows setting exit_code, stdout, and stderr in stubs.
  def subprocess_result(options={})
    defaults = {exit_code: 0, stdout: "", stderr: ""}
    double("subprocess_result", defaults.merge(options))
  end

  before do
    # we don't want unit tests to ever run commands on the system; so we wire
    # in a double to ensure any unexpected messages raise exceptions
    stub_const("Vagrant::Util::Subprocess", subprocess)

    # drivers will blow up on instantiation if they cannot determine the
    # Parallels Desktop version, so wire this stub in automatically
    subprocess.stub(:execute).
      with("prlctl", "--version", an_instance_of(Hash)).
      and_return(subprocess_result(stdout: "prlctl version #{parallels_version}.23456.987654"))

    # drivers also call vm_exists? during init;
    subprocess.stub(:execute).
      with("prlctl", "list", kind_of(String), "--info", "--json", kind_of(Hash)).
      and_return(subprocess_result(exit_code: 0))
  end
end
